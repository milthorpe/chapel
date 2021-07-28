/*
 * Copyright 2021 Hewlett Packard Enterprise Development LP
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "chpl/resolution/resolution-queries.h"

#include "chpl/parsing/parsing-queries.h"
#include "chpl/queries/ErrorMessage.h"
#include "chpl/queries/query-impl.h"
#include "chpl/resolution/scope-queries.h"
#include "chpl/types/all-types.h"
#include "chpl/uast/all-uast.h"

#include <cstdio>
#include <set>
#include <string>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>

namespace chpl {
namespace resolution {

using namespace uast;
using namespace types;

struct Resolver;


static QualifiedType::Kind resolveIntent(const QualifiedType& t);


const QualifiedType& typeForBuiltin(Context* context,
                                    UniqueString name) {
  QUERY_BEGIN(typeForBuiltin, context, name);

  QualifiedType result;

  std::unordered_map<UniqueString,const Type*> map;
  Type::gatherBuiltins(context, map);

  auto search = map.find(name);
  if (search != map.end()) {
    result = QualifiedType(QualifiedType::TYPE, search->second);
  } else {
    assert(false && "Should not be reachable");
  }

  return QUERY_END(result);
}

static QualifiedType typeForLiteral(Context* context, const Literal* literal) {
  const Type* typePtr = nullptr;
  int64_t param = 0; // TODO: replace with Immediate

  if (auto i = literal->toIntLiteral()) {
    typePtr = IntType::get(context, 0);
    param = i->value();
  } else {
    // TODO: handle the other literals as params
  }

  return QualifiedType(QualifiedType::PARAM, typePtr, param);
}

static QualifiedType::Kind qualifiedTypeKindForDecl(const NamedDecl* decl) {
  if (decl->isFunction()) {
    return QualifiedType::FUNCTION;
  } else if (decl->isModule()) {
    return QualifiedType::MODULE;
  } else if (decl->isTypeDecl()) {
    return QualifiedType::TYPE;
  } else if (const VarLikeDecl* vd = decl->toVarLikeDecl()) {
    auto storageKind = vd->storageKind();
    switch (storageKind) {
      case IntentList::DEFAULT:
      case IntentList::INDEX:
        return QualifiedType::UNKNOWN;

      case IntentList::VAR:
      case IntentList::IN:
      case IntentList::OUT:
      case IntentList::INOUT:
        return QualifiedType::VALUE;

      case IntentList::CONST:
      case IntentList::CONST_IN:
        return QualifiedType::CONST;

      case IntentList::CONST_REF:
        return QualifiedType::CONST_REF;

      case IntentList::REF:
        return QualifiedType::REF;

      case IntentList::PARAM:
        return QualifiedType::PARAM;

      case IntentList::TYPE:
        return QualifiedType::TYPE;
    }
    assert(false && "case not handled");
  }
  assert(false && "case not handled");
  return QualifiedType::UNKNOWN;
}

struct Resolver {
  // inputs to the resolution process
  Context* context = nullptr;
  const ASTNode* symbol = nullptr;
  const PoiScope* poiScope = nullptr;
  const SubstitutionsMap* substitutions = nullptr;

  // internal variables
  std::vector<const Scope*> scopeStack;
  bool signatureOnly = false;
  const Block* fnBody = nullptr;

  // results of the resolution process

  // the resolution results for the contained Expressions
  ResolutionResultByPostorderID& byPostorder;
  // the set of POI scopes from which POI functions were used --
  // these are gathered here during resolution in order to
  // allow accurate caching and reuse of instantiations
  PoiInfo poiInfo;

  // set up Resolver to resolve a Module
  Resolver(Context* context,
           const Module* mod,
           ResolutionResultByPostorderID& byPostorder)
    : context(context),
      symbol(mod),
      byPostorder(byPostorder) {

    byPostorder.resize(mod->id().numContainedChildren());
    enterScope(symbol);
  }

  // set up Resolver to resolve a potentially generic Function signature
  Resolver(Context* context,
           const Function* fn,
           ResolutionResultByPostorderID& byPostorder)
    : context(context),
      symbol(fn),
      signatureOnly(true),
      fnBody(fn->body()),
      byPostorder(byPostorder) {

    int bodyPostorder = fnBody->id().postOrderId();
    assert(0 <= bodyPostorder);
    byPostorder.resize(bodyPostorder);
    enterScope(symbol);
  }

  // set up Resolver to resolve an instantiation of a Function signature
  Resolver(Context* context,
           const Function* fn,
           const SubstitutionsMap& substitutions,
           const PoiScope* poiScope,
           ResolutionResultByPostorderID& byPostorder)
    : context(context),
      symbol(fn),
      poiScope(poiScope),
      substitutions(&substitutions),
      signatureOnly(true),
      fnBody(fn->body()),
      byPostorder(byPostorder) {

    poiInfo.poiScope = poiScope;

    int bodyPostorder = fnBody->id().postOrderId();
    assert(0 <= bodyPostorder);
    byPostorder.resize(bodyPostorder);
    enterScope(symbol);
  }

  // set up Resolver to resolve a Function body
  Resolver(Context* context,
           const Function* fn,
           const PoiScope* poiScope,
           const TypedFnSignature* typedFnSignature,
           ResolutionResultByPostorderID& byPostorder)
    : context(context),
      symbol(fn),
      poiScope(poiScope),
      signatureOnly(false),
      fnBody(fn->body()),
      byPostorder(byPostorder) {

    assert(typedFnSignature);
    assert(typedFnSignature->untypedSignature);

    poiInfo.poiScope = poiScope;

    // include any pois required for the signature in the resulting PoiInfo
    poiInfo.accumulate(typedFnSignature->poiInfo);

    byPostorder.resize(fn->id().numContainedChildren());
    enterScope(symbol);

    // set the resolution results for the formals according to
    // the typedFnSignature
    const UntypedFnSignature* uSig = typedFnSignature->untypedSignature;
    assert(typedFnSignature->formalTypes.size() == uSig->formals.size());
    size_t nFormals = uSig->formals.size();
    for (size_t i = 0; i < nFormals; i++) {
      const Formal* formal = uSig->formals[i];
      const auto& qt = typedFnSignature->formalTypes[i];
      int postorder = formal->id().postOrderId();
      assert(0 <= postorder && postorder < (int) byPostorder.size());
      ResolvedExpression& r = byPostorder[postorder];
      r.id = formal->id();
      r.type = qt;
    }
  }


  ResolvedExpression& resultForId(const ID& id) {
    auto postorder = id.postOrderId();
    assert(0 <= postorder);
    if ((size_t) postorder < byPostorder.size()) {
      // OK
    } else {
      byPostorder.resize(postorder+1);
    }
    return byPostorder[postorder];
  }

  QualifiedType typeForId(const ID& id) {
    // if the id is contained within this symbol,
    // get the type information from the resolution result.
    if (id.symbolPath() == symbol->id().symbolPath()) {
      return resultForId(id).type;
    }

    // TODO: handle outer function variables

    // otherwise, use a query to try to look it up top-level.
    return typeForModuleLevelSymbol(context, id);
  }

  QualifiedType typeForAst(const ASTNode* ast) {
    return typeForId(ast->id());
  }

  void enterScope(const ASTNode* ast) {
    if (createsScope(ast->tag())) {
      scopeStack.push_back(scopeForId(context, ast->id()));
    }
  }
  void exitScope(const ASTNode* ast) {
    if (createsScope(ast->tag())) {
      scopeStack.pop_back();
    }
  }

  ResolvedExpression& resultById(ID id) {
    int postorder = id.postOrderId();

    if (postorder < 0) {
      assert(false && "should not be reached");
    } else if ((size_t) postorder < byPostorder.size()) {
      // OK, nothing to do
    } else {
      byPostorder.resize(postorder+1);
    }
    return byPostorder[postorder];
  }
  ResolvedExpression& resultByAst(const ASTNode* ast) {
    return resultById(ast->id());
  }

  bool enter(const Literal* literal) {
    ResolvedExpression& result = resultByAst(literal);
    result.id = literal->id();
    result.type = typeForLiteral(context, literal);
    return false;
  }
  void exit(const Literal* literal) {
  }

  bool enter(const Identifier* ident) {
    assert(scopeStack.size() > 0);
    const Scope* scope = scopeStack.back();
    ResolvedExpression& result = resultByAst(ident);
    result.id = ident->id();

    auto vec = lookupInScope(context, scope, ident,
                             /* checkDecls */ true,
                             /* checkUseImport */ true,
                             /* checkParents */ true,
                             /* checkToplevel */ false,
                             /* findOne */ true);
    if (vec.size() == 0) {
      result.type = QualifiedType(QualifiedType::UNKNOWN,
                                  ErroneousType::get(context));
    } else if (vec.size() > 1) {
      // can't establish the type. If this is in a function
      // call, we'll establish it later anyway.
    } else {
      // vec.size() == 1
      ID id = vec[0].firstId();
      QualifiedType type;
      if (id.isEmpty()) {
        // empty IDs from the scope resolution process are builtins
        type = typeForBuiltin(context, ident->name());
      } else {
        // use the type established at declaration/initialization
        type = typeForId(id);
      }
      result.toId = id;
      result.type = type;
      // if there are multiple ids we should have gotten
      // a multiple definition error at the declarations.
    }
    return false;
  }
  void exit(const Identifier* ident) {
  }

  bool enter(const NamedDecl* decl) {
    assert(scopeStack.size() > 0);
    const Scope* scope = scopeStack.back();

    bool canOverload = false;
    if (const Function* fn = decl->toFunction()) {
      if (fn->isParenless() == false) {
        canOverload = true;
      }
    }

    if (canOverload == false) {
      // check for multiple definitions
      auto vec = lookupNameInScope(context, scope, decl->name(),
                                   /* checkDecls */ true,
                                   /* checkUseImport */ false,
                                   /* checkParents */ false,
                                   /* checkToplevel */ false,
                                   /* findOne */ false);

      if (vec.size() > 0) {
        const BorrowedIdsWithName& m = vec[0];
        if (m.firstId() == decl->id()) {
          if (m.moreIds != nullptr) {
            Location loc = parsing::locateId(context, decl->id());
            auto error =
              ErrorMessage::build(loc, "'%s' has multiple definitions",
                                  decl->name().c_str());
            for (const ID& id: *m.moreIds) {
              if (id != decl->id()) {
                Location curLoc = parsing::locateId(context, id);
                error.addDetail(ErrorMessage::build(curLoc, "redefined here"));
              }
            }
            context->error(error);
          }
        }
      }
    }

    // don't visit e.g. nested functions - these will be resolved
    // when calling them.
    bool visitChildren = !Builder::astTagIndicatesNewIdScope(decl->tag());

    enterScope(decl);

    return visitChildren;
  }

  void exit(const NamedDecl* decl) {
    if (decl->id().postOrderId() < 0) {
      // It's a scoped symbol. Don't try to resolve it now in this
      // traversal. Instead, resolve it e.g. when the function is called.

    } else {
      // Figure out the Kind of the declaration
      auto qtKind = qualifiedTypeKindForDecl(decl);

      // Figure out the Type of the declaration
      // Nested Identifiers and Expressions should already be resolved
      const Type* typePtr = nullptr;

      // Figure out the param value, if any
      int64_t param = -1; // TODO: replace with Immediates

      if (decl->isFunction()) {
        // TODO: function types
        typePtr = nullptr;
      } else if (decl->isTypeDecl()) {
        // TODO: class/record/union/enum types
        typePtr = nullptr;
      } else if (auto var = decl->toVarLikeDecl()) {
        // Figure out variable type based upon:
        //  * the type in the variable declaration
        //  * the initialization expression in the variable declaration
        //  * the initialization expression from split-init

        auto typeExpr = var->typeExpression();
        auto initExpr = var->initExpression();

        if (typeExpr) {
          // get the type we should have already computed postorder
          ResolvedExpression& r = resultByAst(typeExpr);
          // check that the resolution of that expression is a type
          auto kind = r.type.kind();
          if (kind == QualifiedType::TYPE) {
            typePtr = r.type.type();
          } else if (kind != QualifiedType::UNKNOWN) {
            typePtr = ErroneousType::get(context);
            context->error(typeExpr, "Value provided where type expected");
          }
          // otherwise, typePtr can remain nullptr.
        }

        if (initExpr) {
          // compute the type based upon the init expression
          ResolvedExpression& r = resultByAst(initExpr);
          const QualifiedType& initType = r.type;

          // check that the init expression has compatible kind
          if (qtKind == QualifiedType::TYPE &&
              initType.kind() != QualifiedType::TYPE) {
            context->error(initExpr, "Cannot initialize type with value");
          } else if (qtKind == QualifiedType::PARAM &&
                     initType.kind() != QualifiedType::PARAM) {
            context->error(initExpr, "Cannot initialize param with non-param");
          }

          if (initType.kind() == QualifiedType::PARAM) {
            param = initType.param();
          }
          if (typePtr != nullptr) {
            // check that the initExpr type is compatible with declared type
            if (initType.type() != typePtr) {
              context->error(typeExpr, "Cannot initialize this type with that");
              // TODO: better error
              // TODO: implicit conversions and instantiations
            }
          } else {
            // Infer the type of the variable from its initialization expr
            typePtr = initType.type();
          }
        }

        if (const Formal* formal = decl->toFormal()) {
          // Lack of initializer for a formal means the Any type
          if (typeExpr == nullptr && initExpr == nullptr) {
            typePtr = AnyType::get(context);
          }

          // use substitutions computed for formals
          if (substitutions != nullptr) {
            auto search = substitutions->find(formal);
            if (search != substitutions->end()) {
              const QualifiedType& t = search->second;
              typePtr = t.type();
              param = t.param();
            }
          }
        }

        // TODO: handle split init
        // TODO: handle generic & instantiated formal arguments

        if (typePtr == nullptr) {
          context->error(var, "Cannot establish type for %s",
                               var->name().c_str());
          typePtr = ErroneousType::get(context);
        }
      }

      if (typePtr == nullptr) {
        if (qtKind == QualifiedType::FUNCTION ||
            qtKind == QualifiedType::MODULE) {
          // OK, type can be null for now
        } else {
          // type should have been established above
          context->error(decl, "Cannot establish type");
          typePtr = ErroneousType::get(context);
        }
      }

      ResolvedExpression& result = resultById(decl->id());
      result.id = decl->id();
      result.type = QualifiedType(qtKind, typePtr, param);
    }

    exitScope(decl);
  }

  bool enter(const Call* call) {
    return true;
  }
  void exit(const Call* call) {
    assert(scopeStack.size() > 0);
    const Scope* scope = scopeStack.back();

    // Generate a CallInfo for the call
    CallInfo ci;

    if (auto called = call->calledExpression()) {
      if (auto calledIdent = called->toIdentifier()) {
        ci.name = calledIdent->name();
      } else {
        assert(false && "TODO: method calls with Dot called");
      }
    }

    const FnCall* fnCall = call->toFnCall();

    int i = 0;
    for (auto actual : call->actuals()) {
      CallInfoActual ciActual;
      ResolvedExpression& r = resultByAst(actual);
      ciActual.type = r.type;
      if (fnCall && fnCall->isNamedActual(i)) {
        ciActual.byName = fnCall->actualName(i);
      }
      ci.actuals.push_back(ciActual);
      i++;
    }

    CallResolutionResult c = resolveCall(context, call, ci, scope, poiScope);

    // save the most specific candidates in the resolution result for the id
    ResolvedExpression& r = resultByAst(call);
    r.mostSpecific = c.mostSpecific;

    // compute the return types
    QualifiedType retType;
    bool retTypeSet = false;
    for (const TypedFnSignature* candidate : r.mostSpecific) {
      if (candidate != nullptr) {
        QualifiedType t = returnType(context, candidate, poiScope);
        if (retTypeSet && retType.type() != t.type()) {
          context->error(candidate,
                         nullptr,
                         "return intent overload type does not match");
        }
        retType = t;
        retTypeSet = true;
      }
    }
    r.type = retType;

    // gather the poi scopes used when resolving the call
    poiInfo.accumulate(c.poiInfo);
  }

  bool enter(const ASTNode* ast) {
    enterScope(ast);

    bool skipChildren = signatureOnly && ast == fnBody;
    return !skipChildren;
  }
  void exit(const ASTNode* ast) {
    exitScope(ast);
  }
};

const ResolutionResultByPostorderID& resolveModule(Context* context, ID id) {
  QUERY_BEGIN(resolveModule, context, id);

  ResolutionResultByPostorderID& partialResult = QUERY_CURRENT_RESULT;

  auto ast = parsing::idToAst(context, id);
  if (const Module* mod = ast->toModule()) {
    partialResult.resize(mod->id().numContainedChildren());

    Resolver visitor(context, mod, partialResult);
    for (auto child: ast->children()) {
      child->traverse(visitor);
    }
  }

  // take the value out of the partial result in order to return it
  ResolutionResultByPostorderID result;
  result.swap(partialResult);
  return QUERY_END(result);
}

static
const ResolutionResultByPostorderID& partiallyResolvedModule(Context* context,
                                                             ID id) {

  // check for a partial result from a running query
  const ResolutionResultByPostorderID* r =
    QUERY_RUNNING_PARTIAL_RESULT(resolveModule, context, id);
  // if there was a partial result, return it
  if (r != nullptr) {
    return *r;
  }

  // otherwise, run the query to compute the full result
  return resolveModule(context, id);
}

const QualifiedType& typeForModuleLevelSymbol(Context* context, ID id) {
  QUERY_BEGIN(typeForModuleLevelSymbol, context, id);

  QualifiedType result;

  int postOrderId = id.postOrderId();
  if (postOrderId >= 0) {
    // Find the parent scope for the ID - i.e. where the id is declared
    ID parentSymbolId = id.parentSymbolId(context);
    ASTTag parentTag = parsing::idToTag(context, parentSymbolId);
    if (asttags::isModule(parentTag)) {
      auto& r = partiallyResolvedModule(context, parentSymbolId);
      assert((size_t) postOrderId < r.size());
      result = r[postOrderId].type;
    }
  } else {
    QualifiedType::Kind kind = QualifiedType::UNKNOWN;

    auto ast = parsing::idToAst(context, id);
    if (auto* decl = ast->toNamedDecl()) {
      kind = qualifiedTypeKindForDecl(decl);
      // TODO -- compute type
    } else {
      assert(false && "case not handled");
    }

    result = QualifiedType(kind, nullptr);
  }

  return QUERY_END(result);
}


/////// function resolution

static
const owned<UntypedFnSignature>& untypedSignatureQuery(Context* context, ID id)
{
  QUERY_BEGIN(untypedSignatureQuery, context, id);

  auto ast = parsing::idToAst(context, id);
  auto fn = ast->toFunction();

  owned<UntypedFnSignature> result;

  if (fn != nullptr) {
    auto sig = new UntypedFnSignature(fn);
    result = toOwned(sig);
  }

  return QUERY_END(result);
}

const UntypedFnSignature* untypedSignature(Context* context, ID id) {
  const owned<UntypedFnSignature>& r = untypedSignatureQuery(context, id);
  return r.get();
}

static const owned<TypedFnSignature>&
typedSignatureQuery(Context* context,
                    const UntypedFnSignature* untypedSignature,
                    std::vector<types::QualifiedType> formalTypes,
                    TypedFnSignature::WhereClauseResult whereClauseResult,
                    bool needsInstantiation,
                    const TypedFnSignature* instantiatedFrom,
                    const TypedFnSignature* parentFn,
                    PoiInfo poiInfo) {
  QUERY_BEGIN(typedSignatureQuery, context,
              untypedSignature, formalTypes, whereClauseResult,
              needsInstantiation, instantiatedFrom, parentFn, poiInfo);

  auto result = toOwned(new TypedFnSignature());
  result->untypedSignature = untypedSignature;
  result->formalTypes = formalTypes;
  result->whereClauseResult = whereClauseResult;
  result->needsInstantiation = needsInstantiation;
  result->instantiatedFrom = instantiatedFrom;
  result->parentFn = parentFn;
  result->poiInfo = std::move(poiInfo);

  return QUERY_END(result);
}

static std::vector<types::QualifiedType>
getFormalTypes(const Function* fn,
               const ResolutionResultByPostorderID& r) {
  std::vector<types::QualifiedType> formalTypes;
  for (auto formal : fn->formals()) {
    int postorder = formal->id().postOrderId();
    assert(0 <= postorder && postorder < (int) r.size());

    QualifiedType t = r[postorder].type;
    // compute concrete intent
    t = QualifiedType(resolveIntent(t), t.type(), t.param());

    formalTypes.push_back(std::move(t));
  }
  return formalTypes;
}

static bool
anyFormalNeedsInstantiation(const std::vector<types::QualifiedType>& formalTs) {
  bool genericOrUnknown = false;
  for (const auto& qt : formalTs) {
    if (qt.isGenericOrUnknown()) {
      genericOrUnknown = true;
      break;
    }
  }
  return genericOrUnknown;
}

static TypedFnSignature::WhereClauseResult whereClauseResult(
                                     Context* context,
                                     const Function* fn,
                                     const ResolutionResultByPostorderID& r,
                                     bool needsInstantiation) {
  auto whereClauseResult = TypedFnSignature::WHERE_TBD;
  if (const Expression* where = fn->whereClause()) {
    int postorder = where->id().postOrderId();
    assert(0 <= postorder && postorder < (int) r.size());
    const QualifiedType& qt = r[postorder].type;
    if (qt.kind() == QualifiedType::PARAM && qt.type()->isBoolType()) {
      // OK, we know the result of the where clause
      // TODO: handle Immediate
      if (qt.param() != 0) {
        whereClauseResult = TypedFnSignature::WHERE_TRUE;
      } else {
        whereClauseResult = TypedFnSignature::WHERE_FALSE;
      }
    } else if (needsInstantiation) {
      // it's OK, need to establish the value of the where clause later
      whereClauseResult = TypedFnSignature::WHERE_TBD;
    } else {
      // where clause should be resolved by now
      context->error(where,
                     "where clause does not result in a param bool value");
    }
  } else {
    whereClauseResult = TypedFnSignature::WHERE_NONE;
  }

  return whereClauseResult;
}

// Finds a parent function from a function ID
// Returns that parent function, or an empty ID if there was none.
static ID parentFunctionId(Context* context, ID functionId) {
  ID parentSymId = functionId.parentSymbolId(context);
  const Scope* parentScope = scopeForId(context, parentSymId);
  for (const Scope* cur = parentScope; cur != nullptr; cur = cur->parentScope) {
    if (cur->tag == asttags::Function) {
      return cur->id;
    }
  }

  return ID();
}

const TypedFnSignature*
typedSignatureInitial(Context* context,
                      const UntypedFnSignature* untypedSig) {

  const ASTNode* ast = parsing::idToAst(context, untypedSig->functionId);
  const Function* fn = ast->toFunction();

  if (fn == nullptr) {
    return nullptr;
  }

  // look at the parent scopes to find the parent function, if any
  const UntypedFnSignature* parentFnUntyped = nullptr;
  const TypedFnSignature* parentFnTyped = nullptr;
  ID parentFnId = parentFunctionId(context, fn->id());
  if (!parentFnId.isEmpty()) {
    parentFnUntyped = untypedSignature(context, parentFnId);
    parentFnTyped = typedSignatureInitial(context, parentFnUntyped);
  }

  ResolutionResultByPostorderID r;
  Resolver visitor(context, fn, r);
  // visit the formals, return type, where clause
  for (auto child: fn->children()) {
    child->traverse(visitor);
  }

  // now, construct a TypedFnSignature from the result
  std::vector<types::QualifiedType> formalTypes = getFormalTypes(fn, r);
  bool needsInstantiation = anyFormalNeedsInstantiation(formalTypes);
  auto whereResult = whereClauseResult(context, fn, r, needsInstantiation);
  // use an empty poiFnIdsUsed since this is never an instantiation
  std::set<std::pair<ID, ID>> poiFnIdsUsed;

  const auto& result = typedSignatureQuery(context,
                                           untypedSig,
                                           std::move(formalTypes),
                                           whereResult,
                                           needsInstantiation,
                                           /* instantiatedFrom */ nullptr,
                                           /* parentFn */ parentFnTyped,
                                           std::move(poiFnIdsUsed));
  return result.get();
}

const TypedFnSignature* instantiateSignature(Context* context,
                                             const TypedFnSignature* sig,
                                             CallInfo call,
                                             const PoiScope* poiScope) {

  assert(sig->needsInstantiation);

  const UntypedFnSignature* untypedSignature = sig->untypedSignature;
  const ASTNode* ast = parsing::idToAst(context, untypedSignature->functionId);
  const Function* fn = ast->toFunction();

  if (fn == nullptr) {
    return nullptr;
  }

  const TypedFnSignature* parentFnTyped = nullptr;
  if (sig->parentFn) {
    assert(false && "generic child functions not yet supported");
    // TODO: how to compute parentFn for the instantiation?
    // Does the parent function need to be instantiated in some case?
    // Set parentFnTyped somehow.
  }

  auto faMap = FormalActualMap::build(sig, call);
  if (!faMap.mappingIsValid) {
    return nullptr;
  }

  // compute the substitutions
  SubstitutionsMap substitutions;
  for (const FormalActual& entry : faMap.byFormalIdx) {
    if (entry.formalType.isGenericOrUnknown()) {
      substitutions.insert({entry.formal, entry.actualType});
    }
  }

  ResolutionResultByPostorderID r;
  Resolver visitor(context, fn, substitutions, poiScope, r);
  // visit the formals, return type, where clause
  for (auto child: fn->children()) {
    child->traverse(visitor);
  }

  // now, construct a TypedFnSignature from the result
  std::vector<types::QualifiedType> formalTypes = getFormalTypes(fn, r);
  bool needsInstantiation = anyFormalNeedsInstantiation(formalTypes);
  auto whereResult = whereClauseResult(context, fn, r, needsInstantiation);
  PoiInfo poiInfo;
  poiInfo.swap(visitor.poiInfo);

  const auto& result = typedSignatureQuery(context,
                                           untypedSignature,
                                           std::move(formalTypes),
                                           whereResult,
                                           needsInstantiation,
                                           /* instantiatedFrom */ sig,
                                           /* parentFn */ parentFnTyped,
                                           std::move(poiInfo));
  return result.get();
}

static const owned<ResolvedFunction>&
resolvedFunctionByPoisQuery(Context* context,
                            const TypedFnSignature* sig,
                            std::set<std::pair<ID, ID>> poiFnIdsUsed) {
  QUERY_BEGIN(resolvedFunctionByPoisQuery, context, sig, poiFnIdsUsed);

  owned<ResolvedFunction> result;
  // the actual value is set in resolvedFunction after it is computed
  // because computing it generates the poiFnIdsUsed which is part
  // of the key for this query.
  assert(false && "should not be reached");

  return QUERY_END(result);
}

static const ResolvedFunction* const&
resolvedFunctionByInfoQuery(Context* context,
                            const TypedFnSignature* sig,
                            PoiInfo poiInfo) {
  QUERY_BEGIN(resolvedFunctionByInfoQuery, context, sig, poiInfo);

  const UntypedFnSignature* untypedSignature = sig->untypedSignature;
  const ASTNode* ast = parsing::idToAst(context, untypedSignature->functionId);
  const Function* fn = ast->toFunction();

  const PoiScope* poiScope = poiInfo.poiScope;

  PoiInfo resolvedPoiInfo;

  if (fn) {
    owned<ResolvedFunction> resolved = toOwned(new ResolvedFunction());
    resolved->signature = sig;
    resolved->returnIntent = fn->returnIntent();

    Resolver visitor(context, fn, poiScope, sig, resolved->resolutionById);

    // visit the body
    fn->body()->traverse(visitor);

    resolvedPoiInfo.swap(visitor.poiInfo);
    resolvedPoiInfo.resolved = true;
    resolvedPoiInfo.poiScope = nullptr;

    // save the POI info in the resolution result
    resolved->poiInfo = resolvedPoiInfo;

    // Store the result in the query under the POIs used.
    // This should not update the value if there was already one
    // and they are the same.
    QUERY_STORE_RESULT(resolvedFunctionByPoisQuery,
                       context,
                       resolved,
                       sig,
                       resolvedPoiInfo.poiFnIdsUsed);
  } else {
    assert(false && "this query should be called on Functions");
  }

  // Return the unique result from the query (that might have been saved above)
  const owned<ResolvedFunction>& resolved =
   resolvedFunctionByPoisQuery(context, sig, resolvedPoiInfo.poiFnIdsUsed);

  const ResolvedFunction* result = resolved.get();

  return QUERY_END(result);
}

const ResolvedFunction* resolvedFunction(Context* context,
                                         const TypedFnSignature* sig,
                                         const PoiScope* poiScope) {
  // this should only be applied to concrete fns or instantiations
  assert(!sig->needsInstantiation);

  // construct the PoiInfo for this case
  auto poiInfo = PoiInfo(poiScope);

  // lookup in the map using this PoiInfo
  return resolvedFunctionByInfoQuery(context, sig, std::move(poiInfo));
}

struct ReturnTypeInferer {
  // input
  Context* context;
  Function::ReturnIntent returnIntent;
  const ResolutionResultByPostorderID& resolutionById;

  // output
  std::vector<QualifiedType> returnedTypes;

  ReturnTypeInferer(Context* context,
                    const ResolvedFunction& resolvedFn)
    : context(context),
      returnIntent(resolvedFn.returnIntent),
      resolutionById(resolvedFn.resolutionById) {
  }

  bool enter(const Function* fn) {
    return false;
  }
  void exit(const Function* fn) {
  }

  void checkReturn(const Expression* inExpr, const QualifiedType& qt) {
    if (qt.type()->isVoidType()) {
      if (returnIntent == Function::REF) {
        context->error(inExpr, "Cannot return void with ref return intent");
      } else if (returnIntent == Function::PARAM) {
        context->error(inExpr, "Cannot return void with param return intent");
      } else if (returnIntent == Function::TYPE) {
        context->error(inExpr, "Cannot return void with type return intent");
      }
    } else {
      bool ok = true;
      if ((qt.kind() == QualifiedType::TYPE ||
           qt.kind() == QualifiedType::PARAM) &&
          (returnIntent == Function::CONST_REF ||
           returnIntent == Function::REF)) {
        ok = false;
      } else if (returnIntent == Function::TYPE &&
                 qt.kind() != QualifiedType::TYPE) {
        ok = false;
      } else if (returnIntent == Function::PARAM &&
                 qt.kind() != QualifiedType::PARAM) {
        ok = false;
      }
      if (!ok) {
        context->error(inExpr, "cannot return it with provided return intent");
      }
    }
  }

  void noteVoidReturnType(const Expression* inExpr) {
    auto voidType = QualifiedType(QualifiedType::VALUE, VoidType::get(context));
    returnedTypes.push_back(voidType);

    checkReturn(inExpr, voidType);
  }
  void noteReturnType(const Expression* expr, const Expression* inExpr) {
    int postorder = expr->id().postOrderId();
    assert(0 <= postorder && postorder < (int)resolutionById.size());
    const QualifiedType& qt = resolutionById[postorder].type;

    QualifiedType::Kind kind = qt.kind();
    const Type* type = qt.type();

    checkReturn(inExpr, qt);

    switch (returnIntent) {
      case Function::DEFAULT_RETURN_INTENT:
        kind = QualifiedType::VALUE;
        break;
      case Function::CONST:
        kind = QualifiedType::CONST_VALUE;
        break;
      case Function::CONST_REF:
        kind = QualifiedType::CONST_REF;
        break;
      case Function::REF:
        kind = QualifiedType::REF;
        break;
      case Function::PARAM:
        kind = QualifiedType::PARAM;
        break;
      case Function::TYPE:
        kind = QualifiedType::TYPE;
        break;
    }

    returnedTypes.push_back(QualifiedType(kind, type));
  }

  QualifiedType returnedType() {
    if (returnedTypes.size() == 0) {
      return QualifiedType(QualifiedType::VALUE, VoidType::get(context));
    } else if (returnedTypes.size() == 1) {
      return returnedTypes[0];
    } else {
      assert(false && "TODO");
    }
  }

  bool enter(const Return* ret) {
    if (const Expression* expr = ret->value()) {
      noteReturnType(expr, ret);
    } else {
      noteVoidReturnType(ret);
    }
    return false;
  }
  void exit(const Return* ret) {
  }

  bool enter(const Yield* ret) {
    noteReturnType(ret->value(), ret);
    return false;
  }
  void exit(const Yield* ret) {
  }

  bool enter(const ASTNode* ast) {
    return true;
  }
  void exit(const ASTNode* ast) {
  }
};

const QualifiedType& returnType(Context* context,
                                const TypedFnSignature* sig,
                                const PoiScope* poiScope) {
  QUERY_BEGIN(returnType, context, sig, poiScope);

  // this should only be applied to concrete fns or instantiations
  assert(!sig->needsInstantiation);

  const UntypedFnSignature* untypedSignature = sig->untypedSignature;
  const ASTNode* ast = parsing::idToAst(context, untypedSignature->functionId);
  const Function* fn = ast->toFunction();

  QualifiedType result;

  if (fn) {
    if (const Expression* retType = fn->returnType()) {
      // resolve the return type
      ResolutionResultByPostorderID resolutionById;
      Resolver visitor(context, fn, poiScope, sig, resolutionById);
      retType->traverse(visitor);
      int postorder = retType->id().postOrderId();
      assert(0 <= postorder && postorder < (int) resolutionById.size());
      result = resolutionById[postorder].type;
    } else {
      // resolve the function body
      const ResolvedFunction* rFn = resolvedFunction(context, sig, poiScope);
      // infer the return type
      ReturnTypeInferer visitor(context, *rFn);
      fn->body()->traverse(visitor);
      result = visitor.returnedType();
    }
  }

  return QUERY_END(result);
}

// TODO move these to a core logic of resolution file
static QualifiedType::Kind resolveIntent(const QualifiedType& t) {
  if (t.type()->isPrimitiveType()) {
    if (t.kind() == QualifiedType::UNKNOWN || t.kind() == QualifiedType::CONST)
      return QualifiedType::CONST_VALUE;
  } else if (t.isGenericOrUnknown()) {
    return QualifiedType::UNKNOWN;
  } else {
    assert(false && "TODO");
  }
  return t.kind();
}

static bool canPassInitial(const QualifiedType& actualType,
                           const QualifiedType& formalType) {
  // TODO: pull logic from canDispatch
  if (actualType.type() == formalType.type()) return true;

  if (actualType.type()->isIntType() &&
      formalType.type()->isRealType()) return true;

  if (formalType.kind() == QualifiedType::UNKNOWN) return true;

  return false;
}

static bool canPass(const QualifiedType& actualType,
                    const QualifiedType& formalType) {
  // TODO: pull logic from canDispatch
  if (actualType.type() == formalType.type()) return true;
  if (formalType.type()->isAnyType()) return true;

  if (actualType.type()->isIntType() &&
      formalType.type()->isRealType()) return true;

  return false;
}

// returns nullptr if the candidate is not applicable,
// or the result of typedSignatureInitial if it is.
static const TypedFnSignature*
doIsCandidateApplicableInitial(Context* context,
                               const ID& candidateId,
                               const CallInfo& call) {

  auto uSig = untypedSignature(context, candidateId);
  // First, check that the untyped properties allow a match:
  //  * number of arguments
  //  * names of arguments
  //  * method-ness
  //  * ref-ness

  auto faMap = FormalActualMap::build(uSig, call);
  if (!faMap.mappingIsValid) {
    return nullptr;
  }

  // TODO: check method-ness
  // TODO: reason failed

  auto initialTypedSignature = typedSignatureInitial(context, uSig);
  // Next, check that the types are compatible
  size_t formalIdx = 0;
  for (const FormalActual& entry : faMap.byFormalIdx) {
    const auto& actualType = entry.actualType;
    const auto& formalType = initialTypedSignature->formalTypes[formalIdx];
    bool ok = canPassInitial(actualType, formalType);
    if (!ok) {
      return nullptr;
    }

    formalIdx++;
  }

  // check that the where clause applies
  if (initialTypedSignature->whereClauseResult==TypedFnSignature::WHERE_FALSE) {
    return nullptr;
  }

  return initialTypedSignature;
}

// returns nullptr if the candidate is not applicable,
// or the result of an instantiated typedSignature if it is.
static const TypedFnSignature*
doIsCandidateApplicableInstantiating(Context* context,
                                     const TypedFnSignature* typedSignature,
                                     const CallInfo& call,
                                     const PoiScope* poiScope) {

  const TypedFnSignature* instantiated =
    instantiateSignature(context, typedSignature, call, poiScope);

  if (instantiated == nullptr)
    return nullptr;

  // Next, check that the types are compatible
  size_t nActuals = call.actuals.size();
  for (size_t i = 0; i < nActuals; i++) {
    const QualifiedType& actualType = call.actuals[i].type;
    const QualifiedType& formalType = instantiated->formalTypes[i];
    bool ok = canPass(actualType, formalType);
    if (!ok)
      return nullptr;
  }

  // check that the where clause applies
  if (instantiated->whereClauseResult == TypedFnSignature::WHERE_FALSE)
    return nullptr;

  return instantiated;
}

static const TypedFnSignature* const&
isCandidateApplicableInitialQuery(Context* context,
                                  ID candidateId,
                                  CallInfo call) {

  QUERY_BEGIN(isCandidateApplicableInitialQuery, context, candidateId, call);

  const TypedFnSignature* result =
    doIsCandidateApplicableInitial(context, candidateId, call);

  return QUERY_END(result);
}

const std::vector<const TypedFnSignature*>&
filterCandidatesInitial(Context* context,
                        std::vector<BorrowedIdsWithName> lst,
                        CallInfo call) {
  QUERY_BEGIN(filterCandidatesInitial, context, lst, call);

  std::vector<const TypedFnSignature*> result;

  for (const BorrowedIdsWithName& ids : lst) {
    if (ids.moreIds == nullptr) {
      const TypedFnSignature* s =
        isCandidateApplicableInitialQuery(context, ids.id, call);
      if (s != nullptr) {
        result.push_back(s);
      }
    } else {
      for (const ID& id : *ids.moreIds) {
        const TypedFnSignature* s =
          isCandidateApplicableInitialQuery(context, id, call);
        if (s != nullptr) {
          result.push_back(s);
        }
      }
    }
  }

  return QUERY_END(result);
}

void
filterCandidatesInstantiating(Context* context,
                              std::vector<const TypedFnSignature*> lst,
                              CallInfo call,
                              const Scope* inScope,
                              const PoiScope* inPoiScope,
                              std::vector<const TypedFnSignature*>& result) {

  // Performance: Would it help to make this a query?
  // (I left it not as a query since it runs some other queries
  //  and seems like it might have limited ability for reuse).
  const PoiScope* instantiationPoiScope = nullptr;

  for (const TypedFnSignature* typedSignature : lst) {
    if (typedSignature->needsInstantiation) {
      if (instantiationPoiScope == nullptr) {
        instantiationPoiScope =
          pointOfInstantiationScope(context, inScope, inPoiScope);
      }

      const TypedFnSignature* instantiated =
        doIsCandidateApplicableInstantiating(context,
                                             typedSignature,
                                             call,
                                             instantiationPoiScope);
      if (instantiated != nullptr) {
        result.push_back(instantiated);
      }
    } else {
      // if it's already concrete, we already know it is a candidate.
      result.push_back(typedSignature);
    }
  }
}

const MostSpecificCandidates&
findMostSpecificCandidates(Context* context,
                           std::vector<const TypedFnSignature*> lst,
                           CallInfo call) {
  QUERY_BEGIN(findMostSpecificCandidates, context, lst, call);

  MostSpecificCandidates result;

  if (lst.size() > 1) {
    // TODO: find most specific -- pull over disambiguation code
    // TODO: handle return intent overloading
    // TODO: this is demo code
    if (call.actuals.size() > 1 &&
        call.actuals[1].type.type()->isIntType()) {
      result.candidates[MostSpecificCandidates::REF] = lst[0];
    } else {
      result.candidates[MostSpecificCandidates::REF] = lst[lst.size()-1];
    }
  }
  if (lst.size() == 1) {
    result.candidates[MostSpecificCandidates::REF] = lst[0];
  }

  return QUERY_END(result);
}

static std::vector<BorrowedIdsWithName>
lookupCalledExpr(Context* context,
                 const Scope* scope,
                 const Call* call,
                 std::unordered_set<const Scope*>& visited) {

  std::vector<BorrowedIdsWithName> ret;

  if (auto op = call->toOpCall()) {
    auto vec = lookupNameInScopeWithSet(context, scope, op->op(),
                                        /* checkDecls */ true,
                                        /* checkUseImport */ true,
                                        /* checkParents */ true,
                                        /* checkToplevel */ false,
                                        /* findOne */ false,
                                        visited);
    ret.swap(vec);
  } else if (const Expression* called = call->calledExpression()) {
    auto vec = lookupInScopeWithSet(context, scope, called,
                                    /* checkDecls */ true,
                                    /* checkUseImport */ true,
                                    /* checkParents */ true,
                                    /* checkToplevel */ false,
                                    /* findOne */ false,
                                    visited);
    ret.swap(vec);
  }

  return ret;
}


static
void accumulatePoisUsedByResolvingBody(Context* context,
                                       const TypedFnSignature* signature,
                                       const PoiScope* poiScope,
                                       PoiInfo& poiInfo) {

  if (signature == nullptr) {
    return;
  }

  assert(!signature->needsInstantiation);

  if (signature->instantiatedFrom == nullptr) {
    // if it's not an instantiation, no need to gather POIs
    return;
  }

  // resolve the body
  const ResolvedFunction* r = resolvedFunction(context, signature, poiScope);

  // gather the POI scopes from instantiating the function body
  poiInfo.accumulate(r->poiInfo);
}

CallResolutionResult resolveCall(Context* context,
                                 const Call* call,
                                 CallInfo ci,
                                 const Scope* inScope,
                                 const PoiScope* inPoiScope) {

  // search for candidates at each POI until we have found a candidate
  std::vector<const TypedFnSignature*> candidates;
  size_t firstPoiCandidate = 0;
  std::unordered_set<const Scope*> visited;
  PoiInfo poiInfo;

  // first, look for candidates without using POI.

  {
    // compute the potential functions that it could resolve to
    auto v = lookupCalledExpr(context, inScope, call, visited);

    // filter without instantiating yet
    const auto& initialCandidates = filterCandidatesInitial(context, v, ci);

    // find candidates, doing instantiation if necessary
    filterCandidatesInstantiating(context,
                                  initialCandidates,
                                  ci,
                                  inScope,
                                  inPoiScope,
                                  candidates);

    firstPoiCandidate = candidates.size();
  }

  // next, look for candidates using POI
  for (const PoiScope* curPoi = inPoiScope;
       curPoi != nullptr;
       curPoi = curPoi->inFnPoi) {

    // stop if any candidate has been found.
    if (candidates.empty() == false) {
      break;
    }

    // compute the potential functions that it could resolve to
    auto v = lookupCalledExpr(context, curPoi->inScope, call, visited);

    // filter without instantiating yet
    const auto& initialCandidates = filterCandidatesInitial(context, v, ci);

    // find candidates, doing instantiation if necessary
    filterCandidatesInstantiating(context,
                                  initialCandidates,
                                  ci,
                                  inScope,
                                  inPoiScope,
                                  candidates);
  }

  // find most specific candidates / disambiguate
  MostSpecificCandidates mostSpecific = findMostSpecificCandidates(context,
                                                                   candidates,
                                                                   ci);

  // note any most specific candidates from POI in poiFnIdsUsed.
  {
    size_t n = candidates.size();
    for (size_t i = firstPoiCandidate; i < n; i++) {
      for (const TypedFnSignature* candidate : mostSpecific) {
        if (candidate != nullptr) {
          poiInfo.poiFnIdsUsed.insert(
              std::make_pair(call->id(),
                             candidate->untypedSignature->functionId));
        }
      }
    }
  }

  // fully resolve each candidate function and gather poiScopesUsed.

  // figure out the poiScope to use
  const PoiScope* instantiationPoiScope = nullptr;
  bool anyInstantiated = false;

  for (const TypedFnSignature* candidate : mostSpecific) {
    if (candidate != nullptr && candidate->instantiatedFrom != nullptr) {
      anyInstantiated = true;
      break;
    }
  }

  if (anyInstantiated) {
    instantiationPoiScope =
      pointOfInstantiationScope(context, inScope, inPoiScope);
    poiInfo.poiScope = instantiationPoiScope;
  }

  for (const TypedFnSignature* candidate : mostSpecific) {
    if (candidate != nullptr) {
      accumulatePoisUsedByResolvingBody(context, candidate,
                                        instantiationPoiScope, poiInfo);
    }
  }

  return CallResolutionResult(mostSpecific, std::move(poiInfo));
}


} // end namespace resolution
} // end namespace chpl
