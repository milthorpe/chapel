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

#ifndef CHAPEL_PY_ITERATOR_SUPPORT_H
#define CHAPEL_PY_ITERATOR_SUPPORT_H

#define PY_SSIZE_T_CLEAN
#include "Python.h"
#include "chpl/framework/Context.h"
#include "core-types.h"

struct IterAdapterBase {
  virtual ~IterAdapterBase() = default;
  virtual const chpl::uast::AstNode* next() = 0;
};

template <typename IterPair>
struct IterAdapter : IterAdapterBase {
 private:
  using IterType = decltype(std::declval<IterPair>().begin());
  IterType current;
  IterType end;

 public:
  IterAdapter(IterPair pair) : current(pair.begin()), end(pair.end()) {}

  const chpl::uast::AstNode* next() override {
    if (current == end) return nullptr;
    return *(current++);
  }
};

typedef struct {
  PyObject_HEAD
  IterAdapterBase* iterAdapter;
  PyObject* contextObject;
} AstIterObject;
extern PyTypeObject AstIterType;

void setupAstIterType();

int AstIterObject_init(AstIterObject* self, PyObject* args, PyObject* kwargs);
void AstIterObject_dealloc(AstIterObject* self);
PyObject* AstIterObject_iter(AstIterObject *self);
PyObject* AstIterObject_next(AstIterObject *self);

typedef struct {
  PyObject_HEAD
  int current;
  int num;
  const void* container;
  chpl::UniqueString (*nameGetter)(const void*, int);
  const chpl::uast::AstNode* (*childGetter)(const void*, int);
  PyObject* contextObject;
} AstCallIterObject;
extern PyTypeObject AstCallIterType;

void setupAstCallIterType();

int AstCallIterObject_init(AstCallIterObject* self, PyObject* args, PyObject* kwargs);
void AstCallIterObject_dealloc(AstCallIterObject* self);
PyObject* AstCallIterObject_iter(AstCallIterObject *self);
PyObject* AstCallIterObject_next(AstCallIterObject *self);


PyObject* wrapIterAdapter(ContextObject* context, IterAdapterBase* iterAdapter);

template <typename IterPair>
static IterAdapterBase* mkIterPair(const IterPair& pair) {
  return new IterAdapter<decltype(pair)>(pair);
}

template <typename IterPair>
static PyObject* wrapIterPair(ContextObject* context, const IterPair& pair) {
  return wrapIterAdapter(context, new IterAdapter<decltype(pair)>(pair));
}

#endif // CHAPEL_PY_ITERATOR_SUPPORT_H
