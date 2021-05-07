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

#include "chpl/uast/Loop.h"

namespace chpl {
namespace uast {


Loop::Loop(asttags::ASTTag tag, ASTList children, int32_t statementChildNum,
           bool usesDo)
  : ControlFlow(tag, std::move(children)),
    statementChildNum_(statementChildNum),
    usesDo_(usesDo) {

#ifndef NDEBUG
  assert(statementChildNum_ >= 0);
  assert(statementChildNum < this->numChildren());
#endif

}

Loop::~Loop() {
}


} // namespace uast
} // namespace chpl
