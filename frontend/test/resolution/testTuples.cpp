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
#include "chpl/resolution/scope-queries.h"
#include "chpl/types/all-types.h"
#include "chpl/uast/Identifier.h"
#include "chpl/uast/Module.h"
#include "chpl/uast/Record.h"
#include "chpl/uast/TupleDecl.h"
#include "chpl/uast/Variable.h"

// assumes the last statement is a variable declaration for x.
// returns the type of that.
static void test1() {
  printf("test1\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  var x = (1, 2);
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  assert(tt->isStarTuple() == true);
  assert(tt->numElements() == 2);
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isIntType());

  auto rt = tt->toReferentialTuple(context);
  assert(rt == tt);

  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test2() {
  printf("test2\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  type x = (int, real);
                )"""");

  assert(qt.kind() == QualifiedType::TYPE);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  assert(tt->isStarTuple() == false);
  assert(tt->numElements() == 2);
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isIntType());
  assert(tt->elementType(1).kind() == QualifiedType::VAR);
  assert(tt->elementType(1).type()->isRealType());
}


static void test3() {
  printf("test3\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { }
                  var r: R;
                  var x = (r, r);
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  assert(tt->numElements() == 2);
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::REF);
  assert(tt->elementType(0).type()->isRecordType());

  auto rt = tt->toReferentialTuple(context);
  assert(rt == tt);

  auto vt = tt->toValueTuple(context);
  assert(vt != tt);
  assert(vt->numElements() == 2);
  assert(vt->elementType(0) == vt->elementType(1));
  assert(vt->elementType(0).kind() == QualifiedType::VAR);
  assert(vt->elementType(0).type()->isRecordType());
}

static void test4() {
  printf("test4\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { }
                  type x = (R, R);
                )"""");

  assert(qt.kind() == QualifiedType::TYPE);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  assert(tt->numElements() == 2);
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isRecordType());

  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);

  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test5() {
  printf("test5\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveQualifiedTypeOfX(context,
                R""""(
                  record R { }
                  var r: R;
                  var x = (r, r);
                )"""");

  assert(qt.kind() == QualifiedType::VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  assert(tt->numElements() == 2);
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isRecordType());

  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);

  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test6() {
  printf("test6\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { }
                  proc R.init() { }
                  proc R.deinit() { }
                  proc f() {
                    var r: R;
                    return (r, r);
                  }
                  var x = f();
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);
  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test7() {
  printf("test7\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { }
                  var r: R;
                  var glob = (r, r);
                  proc f() ref {
                    return glob;
                  }
                  var x = f();
                )"""");

  assert(qt.kind() == QualifiedType::REF);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);
  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test8() {
  printf("test8\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { }
                  proc f() : (R, R) {
                    var r: R;
                    return (r, r);
                  }
                  var x = f();
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();
  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);
  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test9() {
  printf("test9\n");
  Context ctx;
  Context* context = &ctx;

  auto M = parseModule(context,
                R""""(
                  var (a, (b, c)) = (1, (2.0, 3));
                )"""");

  assert(M->numStmts() == 1);
  const TupleDecl* td = M->stmt(0)->toTupleDecl();
  assert(td);
  auto a = td->decl(0)->toVariable();
  assert(a);
  auto innerTd = td->decl(1)->toTupleDecl();
  assert(innerTd);
  auto b = innerTd->decl(0)->toVariable();
  assert(b);
  auto c = innerTd->decl(1)->toVariable();
  assert(c);

  const ResolutionResultByPostorderID& rr = resolveModule(context, M->id());
  auto aQt = rr.byAst(a).type();
  auto bQt = rr.byAst(b).type();
  auto cQt = rr.byAst(c).type();
  assert(aQt.kind() == QualifiedType::VAR);
  assert(aQt.type() == IntType::get(context, 0));
  assert(bQt.kind() == QualifiedType::VAR);
  assert(bQt.type() == RealType::get(context, 0));
  assert(cQt.kind() == QualifiedType::VAR);
  assert(cQt.type() == IntType::get(context, 0));
}

static void test9b() {
  printf("test9b\n");
  Context ctx;
  Context* context = &ctx;

  {
    ErrorGuard guard(context);

    std::string program = R"""(
      var (a, b) = (1, 2);

      var xa = a;
      var xb = b;
    )""";

    auto vars = resolveTypesOfVariables(context, program, {"xa", "xb"});
    assert(vars["xa"].type()->isIntType());
    assert(vars["xb"].type()->isIntType());
  }
  {
    context->advanceToNextRevision(false);
    ErrorGuard guard(context);

    std::string program = R"""(
    var ((a, b), (c, d)) = ((1, "hello"), (42.0, 5:uint));

    var xa = a;
    var xb = b;
    var xc = c;
    var xd = d;
    )""";

    auto vars = resolveTypesOfVariables(context, program,
                                        {"xa", "xb", "xc", "xd"});
    assert(vars["xa"].type()->isIntType());
    assert(vars["xb"].type()->isStringType());
    assert(vars["xc"].type()->isRealType());
    assert(vars["xd"].type()->isUintType());
  }
  {
    context->advanceToNextRevision(false);
    ErrorGuard guard(context);

    std::string program = R"""(
    proc foo() {
      return ((1, ("two", 3.0)), ((4:uint, b"five"), 6.0i));
    }

    var ((a, (b, c)), ((d, e), f)) = foo();
    var xa = a;
    var xb = b;
    var xc = c;
    var xd = d;
    var xe = e;
    var xf = f;
    )""";

    auto vars = resolveTypesOfVariables(context, program,
                                        {"xa", "xb", "xc", "xd", "xe", "xf"});
    assert(vars["xa"].type()->isIntType());
    assert(vars["xb"].type()->isStringType());
    assert(vars["xc"].type()->isRealType());
    assert(vars["xd"].type()->isUintType());
    assert(vars["xe"].type()->isBytesType());
    assert(vars["xf"].type()->isImagType());
  }
}

static void test10() {
  printf("test10\n");
  Context ctx;
  Context* context = &ctx;

  auto M = parseModule(context,
                R""""(
                  const (a, (b, c)) = (1, (2.0, 3));
                )"""");

  assert(M->numStmts() == 1);
  const TupleDecl* td = M->stmt(0)->toTupleDecl();
  assert(td);
  auto a = td->decl(0)->toVariable();
  assert(a);
  auto innerTd = td->decl(1)->toTupleDecl();
  assert(innerTd);
  auto b = innerTd->decl(0)->toVariable();
  assert(b);
  auto c = innerTd->decl(1)->toVariable();
  assert(c);

  const ResolutionResultByPostorderID& rr = resolveModule(context, M->id());
  auto aQt = rr.byAst(a).type();
  auto bQt = rr.byAst(b).type();
  auto cQt = rr.byAst(c).type();
  assert(aQt.kind() == QualifiedType::CONST_VAR);
  assert(aQt.type() == IntType::get(context, 0));
  assert(bQt.kind() == QualifiedType::CONST_VAR);
  assert(bQt.type() == RealType::get(context, 0));
  assert(cQt.kind() == QualifiedType::CONST_VAR);
  assert(cQt.type() == IntType::get(context, 0));
}

static void test11() {
  printf("test11\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  proc f(in arg: (real, real)) { return arg; }
                  var x = f( (1,2) );
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();

  assert(tt->numElements() == 2);
  assert(tt->isStarTuple());
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isRealType());
}

static void test11b() {
  printf("test11b\n");
  auto uctx = buildStdContext();
  auto context = uctx.get();
  ErrorGuard guard(context);

  // Exercises a case where the frontend was attempting to resolve an '='
  // operator between "(a, b)" and "foo()", and naturally running into
  // constness errors. The Resolver handles this already, so we shouldn't ever
  // bother to resolve that assignment.
  auto t = resolveTypeOfX(context,
                R""""(
                record R { var i : int; }

                proc foo() {
                  return (new R(5), new R(42));
                }

                proc helper() {
                  var a : R;
                  var b : R;

                  (a, b) = foo();

                  return a;
                }

                var x = helper();
                )"""");

  assert(t->isRecordType());
}

static void test12() {
  printf("test12\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { }
                  proc f(in arg: (R, R)) { return arg; }
                  var r: R;
                  var x = f( (r, r) );
                )"""");


  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();

  assert(tt->numElements() == 2);
  assert(tt->isStarTuple());
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isRecordType());

  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);
  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test13() {
  printf("test13\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  record R { param p; }
                  proc f(in arg: (R, R)) { return arg; }
                  var r: R(1);
                  var x = f( (r, r) );
                )"""");


  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();

  assert(tt->numElements() == 2);
  assert(tt->isStarTuple());
  assert(tt->elementType(0) == tt->elementType(1));
  assert(tt->elementType(0).kind() == QualifiedType::VAR);
  assert(tt->elementType(0).type()->isRecordType());
  auto rec = tt->elementType(0).type()->toRecordType();
  assert(rec->instantiatedFrom() != nullptr);

  auto rt = tt->toReferentialTuple(context);
  assert(rt != tt);
  auto vt = tt->toValueTuple(context);
  assert(vt == tt);
}

static void test14() {
  printf("test14\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  proc f(x: int, (y, z): (real, int)) { return (x, y, z); }
                  var x = f( 1, (2.0, 3) );
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();

  assert(tt->numElements() == 3);
  assert(!tt->isStarTuple());
  assert(tt->elementType(0).type()->isIntType());
  assert(tt->elementType(1).type()->isRealType());
  assert(tt->elementType(2).type()->isIntType());
}

static void test15() {
  printf("test15\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveTypeOfXInit(context,
                R""""(
                  var tup = (1, 2);
                  var x = ( (... tup), 3.0);
                )"""");

  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();

  assert(tt->numElements() == 3);
  assert(!tt->isStarTuple());
  assert(tt->elementType(0).type()->isIntType());
  assert(tt->elementType(1).type()->isIntType());
  assert(tt->elementType(2).type()->isRealType());
}

static void test16() {
  printf("test16\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveQualifiedTypeOfX(context,
                R""""(
                  proc helper(a: int, b: real) { return b; }
                  var tup = (1, 2.0);
                  var x = helper( (... tup) );
                )"""");

  assert(qt.kind() == QualifiedType::VAR);
  assert(qt.type()->isRealType());
}

static void test17() {
  printf("test17\n");
  Context ctx;
  Context* context = &ctx;

  auto qt = resolveQualifiedTypeOfX(context,
                R""""(
                  var x : 3*int;
                )"""");

  assert(qt.kind() == QualifiedType::VAR);
  assert(qt.type()->isTupleType());
  auto tt = qt.type()->toTupleType();

  assert(tt->numElements() == 3);
  assert(tt->isStarTuple());
  assert(tt->elementType(0).type()->isIntType());
  assert(tt->elementType(1).type()->isIntType());
  assert(tt->elementType(2).type()->isIntType());
}

static void argHelper(std::string formal, std::string actual,
                           bool shouldResolve) {
  Context ctx;
  Context* context = &ctx;
  ErrorGuard guard(context);

  std::string program = R"""(
    operator =(ref lhs: _tuple, const ref rhs: _tuple) {}

    proc foo(arg: )""" + formal + R"""() {
      return arg;
    }

    var actual = )""" + actual + R"""(;
    var x = foo(actual);
    )""";

  auto m = parseModule(context, std::move(program));
  auto x = findVariable(m, "x");
  auto a = findVariable(m ,"actual");

  const ResolutionResultByPostorderID& rr = resolveModule(context, m->id());

  if (shouldResolve) {
    // 'x' and 'actual' should have the same type
    auto xt = rr.byAst(x).type();
    auto at = rr.byAst(a).type();
    assert(xt.isUnknown() == false);
    assert(xt.isErroneousType() == false);
    assert(xt.hasTypePtr());
    assert(xt.type()->isTupleType());
    assert(xt.type() == at.type());

    auto t = xt.type()->toTupleType();
    std::stringstream str;
    t->stringify(str, chpl::StringifyKind::CHPL_SYNTAX);
    printf("  success: passing %s to %s\n", str.str().c_str(), formal.c_str());
  } else {
    assert(guard.numErrors() == 1);
    assert(guard.error(0)->type() == chpl::NoMatchingCandidates);
    guard.clearErrors();
    printf("  success: cannot pass %s to %s\n", actual.c_str(), formal.c_str());
  }
}

static void testTupleGeneric() {
  printf("testTupleGeneric\n");

  // Basic all-generic cases
  argHelper("(?,)", "(5,)", true);
  argHelper("(?,)", "('hello',)", true);
  argHelper("(?,?)", "(5, 1.0)", true);
  argHelper("(?,?)", "(5, 'hello')", true);
  argHelper("(?,?,?)", "(5, 1.0,'hello')", true);

  // Mixed concrete and generic, still expecting to pass
  argHelper("(int, ?)", "(5, 1.0)", true);
  argHelper("(int, ?)", "(5, 'hello')", true);
  argHelper("(int, ?)", "('hello', 5)", false);

  argHelper("(int, ?, string)", "(5, 42.0, 'hello')", true);
  argHelper("(int, ?, string)", "(5, 5, 'hello')", true);
  argHelper("(int, ?, string)", "(5, 'hi', 'hello')", true);
  argHelper("(int, ?, string)", "('hi', 42.0, 'hello')", false);
  argHelper("(int, ?, string)", "(5, 42.0, 5)", false);

  // Passing a tuples of incorrect size
  argHelper("(int, ?)", "(5,5,5)", false);
  argHelper("(int, ?, ?)", "(5,5)", false);

  // Some 'integral' and 'numeric' tests
  argHelper("(integral, integral)", "(5, 5)", true);
  argHelper("(integral, integral)", "(5, 'hello')", false);

  argHelper("(numeric, numeric)", "(5, 5)", true);
  argHelper("(numeric, numeric)", "(5, 42.0)", true);
  argHelper("(numeric, numeric)", "(5, 'hi')", false);
}

static void test18() {
  printf("test18\n");
  Context ctx;
  Context* context = &ctx;

  auto program = R""""(
                  var t = (1, "hello", 3.0);
                  var x = t(0);
                  var y = t(1);
                  var z = t(2);
                )"""";

  auto m = parseModule(context, std::move(program));

  auto x = findVariable(m, "x");
  auto y = findVariable(m ,"y");
  auto z = findVariable(m ,"z");

  const ResolutionResultByPostorderID& rr = resolveModule(context, m->id());

  assert(rr.byAst(x).type().type()->isIntType());
  assert(rr.byAst(y).type().type()->isStringType());
  assert(rr.byAst(z).type().type()->isRealType());
}

static void test19() {
  printf("test19\n");
  Context ctx;
  Context* context = &ctx;

  auto program = R""""(
                  var t = (1, 2, 3);
                  var x = t(0);
                  var y = t(1);
                  var z = t(2);

                  param a = __primitive("get svec member", t, 0).type == int;
                  param b = __primitive("get svec member", t, 1).type == int;
                )"""";

  auto m = parseModule(context, std::move(program));

  auto x = findVariable(m, "x");
  auto y = findVariable(m ,"y");
  auto z = findVariable(m ,"z");

  auto a = findVariable(m ,"a");
  auto b = findVariable(m ,"b");

  const ResolutionResultByPostorderID& rr = resolveModule(context, m->id());

  assert(rr.byAst(x).type().type()->isIntType());
  assert(rr.byAst(y).type().type()->isIntType());
  assert(rr.byAst(z).type().type()->isIntType());

  ensureParamBool(rr.byAst(a).type(), true);
  ensureParamBool(rr.byAst(b).type(), true);
}

int main() {
  test1();
  test2();
  test3();
  test4();
  test5();
  test6();
  test7();
  test8();
  test9();
  test9b();
  test10();
  test11();
  test11b();
  test12();
  test13();
  test14();
  test15();
  test16();
  test17();
  test18();
  test19();

  testTupleGeneric();

  return 0;
}
