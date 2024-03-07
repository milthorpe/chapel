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
#include "chpl/uast/Variable.h"

static void test1() {
  Context ctx;
  auto context = &ctx;
  QualifiedType qt =  resolveTypeOfXInit(context,
                         R""""(
                         enum color {
                           red, green, blue
                         }

                         var x = color.red;
                         )"""");
  assert(qt.kind() == QualifiedType::PARAM);
  assert(qt.type() && qt.type()->isEnumType());
  assert(qt.param() && qt.param()->isEnumParam());

  auto et = qt.type()->toEnumType();
  auto ep = qt.param()->toEnumParam();
  assert(et->id().contains(ep->value()));
  auto enumAst = parsing::idToAst(context, et->id());
  assert(enumAst && enumAst->isEnum());
  auto elemAst = parsing::idToAst(context, ep->value());
  assert(elemAst && elemAst->isEnumElement());
}

static void test2() {
  Context ctx;
  auto context = &ctx;
  QualifiedType qt =  resolveTypeOfXInit(context,
                         R""""(
                         enum color {
                           red, red, blue
                         }

                         var x = color.red;
                         )"""");
  assert(qt.kind() == QualifiedType::CONST_VAR);
  assert(qt.type() && qt.type()->isEnumType());
}

static void test3() {
  Context ctx;
  auto context = &ctx;
  QualifiedType qt =  resolveTypeOfXInit(context,
                         R""""(
                         enum color {
                           green, blue
                         }

                         var x = color.red;
                         )"""");
  assert(qt.kind() == QualifiedType::UNKNOWN);
  assert(qt.type() && qt.type()->isErroneousType());
}

// Test numeric conversions of enums
static void test4() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      enum color {
        red = 1,
        green,
        blue = 42,
        gold
      }
      param a = color.red : int;
      param b = color.green : int;
      param c = color.blue : int;
      param d = color.gold : int;
      )""", {"a", "b", "c", "d"});

  ensureParamInt(vars.at("a"), 1);
  ensureParamInt(vars.at("b"), 2);
  ensureParamInt(vars.at("c"), 42);
  ensureParamInt(vars.at("d"), 43);
}

static const std::map<std::string, QualifiedType>
enumConstantValues(Context* context, const QualifiedType& qt) {
  assert(qt.isType() && qt.type());
  auto enumType = qt.type()->toEnumType();
  assert(enumType);

  auto id = enumType->id();
  auto enumAst = parsing::idToAst(context, id)->toEnum();
  assert(enumAst);

  std::map<std::string, QualifiedType> result;
  auto& computedMap = computeNumericValuesOfEnumElements(context, id);
  for (auto elem : enumAst->enumElements()) {
    auto it = computedMap.find(elem->id());
    if (it == computedMap.end()) {
      continue;
    }
    result[std::string(elem->name().c_str())] = it->second;
  }

  return result;
}

static void test5() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      enum color {
        red = "hello",
        green,
        blue = 42,
        gold
      }
      type t = color;
      param a = color.red : int;
      param b = color.green : int;
      param c = color.blue : int;
      param d = color.gold : int;
      )""", {"t", "a", "b", "c", "d"});


  // First, ensure that the actual computation marks 'red' as erroneous

  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);

  assert(enumValuesByName.at("red").isErroneousType());
  assert(enumValuesByName.at("green").isUnknown());
  ensureParamInt(enumValuesByName.at("blue"), 42);
  ensureParamInt(enumValuesByName.at("gold"), 43);

  assert(vars.at("a").isUnknown());
  assert(vars.at("b").isUnknown());
  ensureParamInt(vars.at("c"), 42);
  ensureParamInt(vars.at("d"), 43);

  // Expect an error from "hello".
  assert(guard.numErrors() == 1);
  assert(guard.error(0)->type() == ErrorType::EnumInitializerNotInteger);
  guard.realizeErrors();
}

static void test6() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      enum color {
        negative = __primitive("-", 0, 1),
        huge = 0x8000000000000000,
      }
      type t = color;
      param a = color.negative : int;
      param b = color.huge : uint;
      )""", {"t", "a", "b"});


  // First, ensure that the actual computation marks 'red' as erroneous

  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);

  assert(enumValuesByName.at("negative").isErroneousType());
  ensureParamUint(enumValuesByName.at("huge"), 0x8000000000000000);

  assert(vars.at("a").isUnknown());
  ensureParamUint(vars.at("b"), 0x8000000000000000);

  // Expect an error from unfitable types.
  assert(guard.numErrors() == 1);
  assert(guard.error(0)->type() == ErrorType::NoTypeForEnumElem);
  guard.realizeErrors();
}

static void test7() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      enum color {
        red,
        green,
        blue
      }
      type t = color;
      param a = color.red : int;
      param b = color.green : int;
      param c = color.blue : int;
      )""", {"t", "a", "b", "c"});


  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);
  assert(enumValuesByName.empty());

  assert(vars.at("a").isErroneousType());
  assert(vars.at("b").isErroneousType());
  assert(vars.at("c").isErroneousType());

  assert(guard.numErrors() == 3);
  for (auto& err : guard.errors()) {
    assert(err->type() == ErrorType::EnumAbstract);
  }
  guard.realizeErrors();
}

static void test8() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      var x = 1;
      enum color {
        red = x,
        green,
        blue
      }
      type t = color;
      param a = color.red : int;
      param b = color.green : int;
      param c = color.blue : int;
      )""", {"t", "a", "b", "c"});

  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);
  assert(enumValuesByName.at("red").isErroneousType());
  assert(enumValuesByName.at("green").isUnknown());
  assert(enumValuesByName.at("blue").isUnknown());

  assert(vars.at("a").isUnknown());
  assert(vars.at("b").isUnknown());
  assert(vars.at("c").isUnknown());

  assert(guard.numErrors() == 1);
  assert(guard.error(0)->type() == ErrorType::EnumInitializerNotParam);
  guard.realizeErrors();
}

static void test9() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      var x = 1;
      enum color {
        red,
        green = 0,
        blue
      }
      type t = color;
      param a = color.red : int;
      param b = color.green : int;
      param c = color.blue : int;
      )""", {"t", "a", "b", "c"});

  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);
  assert(enumValuesByName.find("red") == enumValuesByName.end());
  ensureParamInt(enumValuesByName.at("green"), 0);
  ensureParamInt(enumValuesByName.at("blue"), 1);

  assert(vars.at("a").isErroneousType());
  ensureParamInt(vars.at("b"), 0);
  ensureParamInt(vars.at("c"), 1);

  assert(guard.numErrors() == 1);
  assert(guard.error(0)->type() == ErrorType::EnumValueAbstract);
  guard.realizeErrors();
}

static void test10() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  auto vars = resolveTypesOfVariables(context,
      R"""(
      enum color {
        red = 0,
        green,
        blue
      }
      type t = color;
      param a = 3 : color;
      )""", {"t", "a"});

  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);
  ensureParamInt(enumValuesByName.at("red"), 0);
  ensureParamInt(enumValuesByName.at("green"), 1);
  ensureParamInt(enumValuesByName.at("blue"), 2);

  assert(vars.at("a").isErroneousType());
  assert(guard.numErrors() == 1);
  assert(guard.error(0)->type() == ErrorType::NoMatchingEnumValue);
  guard.realizeErrors();
}

static void test11() {
  Context ctx;
  auto context = &ctx;
  ErrorGuard guard(context);

  // Production allows multiple constants to have the same numeric value.
  // When casting backwards, the first matching constant is picked.
  auto vars = resolveTypesOfVariables(context,
      R"""(
      enum color {
        red = 0,
        green = 0,
        blue = 1,
        gold = 1,
      }
      type t = color;
      param a = 0 : color;
      param b = 1 : color;
      )""", {"t", "a", "b"});

  auto qtT = vars.at("t");
  auto enumValuesByName = enumConstantValues(context, qtT);
  ensureParamInt(enumValuesByName.at("red"), 0);
  ensureParamInt(enumValuesByName.at("green"), 0);
  ensureParamInt(enumValuesByName.at("blue"), 1);
  ensureParamInt(enumValuesByName.at("gold"), 1);

  auto param0 = vars.at("a").param();
  assert(param0 && param0->isEnumParam());
  assert(param0->toEnumParam()->value().postOrderId() == 1);

  auto param1 = vars.at("b").param();
  assert(param1 && param1->isEnumParam());
  assert(param1->toEnumParam()->value().postOrderId() == 5);
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
  test10();
  test11();
  return 0;
}
