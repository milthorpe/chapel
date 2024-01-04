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

#ifndef CHAPEL_PY_ERROR_TRACKER_H
#define CHAPEL_PY_ERROR_TRACKER_H

#include "Python.h"
#include "chpl/framework/Context.h"
#include "chpl/framework/ErrorBase.h"

typedef struct {
  PyObject_HEAD
  chpl::owned<chpl::ErrorBase> error;
  PyObject* contextObject;
} ErrorObject;
extern PyTypeObject ErrorType;

void setupErrorType();

int ErrorObject_init(ErrorObject* self, PyObject* args, PyObject* kwargs);
void ErrorObject_dealloc(ErrorObject* self);
PyObject* ErrorObject_location(ErrorObject* self, PyObject* args);
PyObject* ErrorObject_message(ErrorObject* self, PyObject* args);
PyObject* ErrorObject_kind(ErrorObject* self, PyObject* args);
PyObject* ErrorObject_type(ErrorObject* self, PyObject* args);

typedef struct {
  PyObject_HEAD
  PyObject* contextObject;
} ErrorManagerObject;
extern PyTypeObject ErrorManagerType;

void setupErrorManagerType();

int ErrorManagerObject_init(ErrorManagerObject* self, PyObject* args, PyObject* kwargs);
void ErrorManagerObject_dealloc(ErrorManagerObject* self);
PyObject* ErrorManagerObject_enter(ErrorManagerObject* self, PyObject* args);
PyObject* ErrorManagerObject_exit(ErrorManagerObject* self, PyObject* args);

class PythonErrorHandler : public chpl::Context::ErrorHandler {
 private:
  std::vector<PyObject*> errorLists;
  PyObject* contextObject; // weak: ContextObject should own the DefaultErrorHandler
 public:
  PythonErrorHandler(PyObject* contextObject) : contextObject(contextObject) {}
  ~PythonErrorHandler() = default;

  PyObject* pushList();
  void popList();
  virtual void report(chpl::Context* context, const chpl::ErrorBase* err) override;
};

#endif
