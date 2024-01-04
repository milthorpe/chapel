/*
 * Copyright 2021-2024 Hewlett Packard Enterprise Development LP
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

#include "test-resolution.h"

#include "chpl/parsing/parsing-queries.h"
#include "chpl/resolution/resolution-queries.h"
#include "chpl/types/ComplexType.h"
#include "chpl/types/IntType.h"
#include "chpl/types/Param.h"
#include "chpl/types/RealType.h"
#include "chpl/uast/Module.h"

static QualifiedType getTypeForFirstStmt(Context* context,
                                         const std::string& program) {
  auto path = UniqueString::get(context, "input.chpl");
  setFileText(context, path, program);

  const ModuleVec& vec = parseToplevel(context, path);
  assert(vec.size() == 1);
  const Module* m = vec[0]->toModule();
  assert(m);
  assert(m->numStmts() == 1);
  auto stmt = m->stmt(0);
  assert(stmt);

  const ResolutionResultByPostorderID& rr = resolveModule(context, m->id());

  const auto& resolvedExpr = rr.byAst(stmt);

  return resolvedExpr.type();
}

static void test1() {
  printf("test1\n");
  Context ctx;

  QualifiedType qt = getTypeForFirstStmt(&ctx,
                                         "__primitive('+', 1, 2);\n");
  assert(qt.hasTypePtr());
  assert(qt.hasParamPtr());

  assert(qt.type() == IntType::get(&ctx, 0));
  assert(qt.param() == IntParam::get(&ctx, 3));
}

static void test2() {
  printf("test2\n");
  Context ctx;

  QualifiedType qt = getTypeForFirstStmt(&ctx,
                                         "__primitive('*', 2.25, 4.25);\n");
  assert(qt.hasTypePtr());
  assert(qt.hasParamPtr());

  assert(qt.type() == RealType::get(&ctx, 0));
  assert(qt.param() == RealParam::get(&ctx, 9.5625));
}

static void test3() {
  printf("test3\n");
  Context ctx;

  QualifiedType qt = getTypeForFirstStmt(&ctx,
                                         "__primitive('+', 3.0, 2.0i);\n");
  assert(qt.hasTypePtr());
  assert(qt.hasParamPtr());

  assert(qt.type() == ComplexType::get(&ctx, 0));
  assert(qt.param() == ComplexParam::get(&ctx, {3.0, 2.0}));
}

static void test4() {
  printf("test4\n");
  Context ctx;
  Context* context = &ctx;
  std::string program = R""""(
    enum myEnum {
      blue,
      red,
      green
    }

    proc param myEnum.isBlue() param
      do return this == myEnum.blue;
    param x = myEnum.green.isBlue();
    param y = myEnum.blue.isBlue();
  )"""";

  auto path = UniqueString::get(context, "test4.chpl");
  setFileText(context, path, program);

  const ModuleVec& vec = parseToplevel(context, path);
  assert(vec.size() == 1);
  const Module* m = vec[0]->toModule();
  assert(m);
  assert(m->numStmts() == 4);
  auto enumDecl = m->stmt(0);
  assert(enumDecl);
  auto blueEnum = enumDecl->child(0);
  auto greenEnum = enumDecl->child(2);
  assert(blueEnum);
  assert(greenEnum);
  auto xStmt = m->stmt(2);
  auto yStmt = m->stmt(3);
  assert(xStmt);
  assert(yStmt);
  const ResolutionResultByPostorderID& rr = resolveModule(context, m->id());
  const auto& resolvedXExpr = rr.byAst(xStmt);
  const auto& resolvedYExpr = rr.byAst(yStmt);
  assert(resolvedXExpr.type().isParamFalse());
  assert(resolvedYExpr.type().isParamTrue());
  auto isBlueXCall = xStmt->child(0);
  assert(isBlueXCall);
  auto isBlueProc = m->stmt(1);
  assert(isBlueProc);
  auto isBlueFn = isBlueProc->toFunction();
  assert(isBlueFn);
  const auto rrIsBlueCall = rr.byAst(isBlueXCall);
  assert(rrIsBlueCall.type().kind() == QualifiedType::Kind::PARAM);
  auto bestCandidate = rrIsBlueCall.mostSpecific().only();
  assert(bestCandidate);
  auto bestFn = bestCandidate.fn();
  assert(bestFn->id() == isBlueFn->id());
  assert(bestFn->formalType(0).isParam());
  assert(bestFn->formalName(0) == UniqueString::get(context, "this"));
  assert(bestFn->formalType(0).param()->isEnumParam());
  assert(bestFn->formalType(0).param()->toEnumParam()->value() == greenEnum->id());
  const ResolvedFunction* rfn = scopeResolveFunction(context, isBlueFn->id());
  const auto tsi = typedSignatureInitial(context, rfn->signature()->untyped());
  assert(tsi->formalType(0).isParam());
}

static void test5() {
  printf("test5\n");
  Context ctx;

  QualifiedType qtString =
  getTypeForFirstStmt(&ctx, "__primitive('string_length_bytes', 'myString');\n");
  ctx.advanceToNextRevision(true);
  QualifiedType qtBytes =
  getTypeForFirstStmt(&ctx, "__primitive('string_length_bytes', b'myBytes');\n");
  assert(qtString.hasTypePtr());
  assert(qtBytes.hasTypePtr());
  assert(qtString.hasParamPtr());
  assert(qtBytes.hasParamPtr());

  assert(qtString.type() == IntType::get(&ctx, 0));
  assert(qtBytes.type() == IntType::get(&ctx, 0));

  assert(qtString.param() == chpl::types::IntParam::get(&ctx, 8));
  assert(qtBytes.param() == chpl::types::IntParam::get(&ctx, 7));
}

int main() {
  test1();
  test2();
  test3();
  test4();
  test5();

  return 0;
}
