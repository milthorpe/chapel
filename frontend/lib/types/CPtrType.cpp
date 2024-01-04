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

#include "chpl/types/CPtrType.h"

#include "chpl/framework/query-impl.h"
#include "chpl/resolution/intents.h"
#include "chpl/types/Param.h"
#include "chpl/types/VoidType.h"
#include "chpl/resolution/can-pass.h"

namespace chpl {
namespace types {

const owned<CPtrType>& CPtrType::getCPtrType(Context* context,
                                             const CPtrType* instantiatedFrom,
                                             const Type* eltType) {
  QUERY_BEGIN(getCPtrType, context, instantiatedFrom, eltType);
  auto result = toOwned(new CPtrType(instantiatedFrom, eltType));
  return QUERY_END(result);
}

bool CPtrType::isEltTypeInstantiationOf(Context* context, const CPtrType* other) const {
  auto r = resolution::canPass(context,
                               QualifiedType(QualifiedType::TYPE, eltType_),
                               QualifiedType(QualifiedType::TYPE, other->eltType_));
  // instantiation and same-type passing are allowed here
  return r.passes() && !r.promotes() && !r.converts();
}

const CPtrType* CPtrType::get(Context* context) {
  return CPtrType::getCPtrType(context,
                               /* instantiatedFrom */ nullptr,
                               /* eltType */ nullptr).get();
}

const CPtrType* CPtrType::get(Context* context, const Type* eltType) {
  return CPtrType::getCPtrType(context,
                               /* instantiatedFrom */ CPtrType::get(context),
                               eltType).get();
}

const CPtrType* CPtrType::getCVoidPtrType(Context* context) {
  return CPtrType::get(context, VoidType::get(context));
}

const ID& CPtrType::getId(Context* context) {
  QUERY_BEGIN(getId, context);
  UniqueString path = UniqueString::get(context, "CTypes.c_ptr");
  ID result { path, -1, 0 };
  return QUERY_END(result);
}

void CPtrType::stringify(std::ostream& ss,
                         chpl::StringifyKind stringKind) const {
  USTR("c_ptr").stringify(ss, stringKind);

  if (eltType_) {
    ss << "(";
    eltType_->stringify(ss, stringKind);
    ss << ")";
  }
}

} // end namespace types
} // end namespace chpl
