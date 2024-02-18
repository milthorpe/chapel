/*
 * Copyright 2023-2024 Hewlett Packard Enterprise Development LP
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

#define PY_SSIZE_T_CLEAN
#include "Python.h"
#include "chpl/framework/Context.h"
#include "chpl/parsing/parsing-queries.h"
#include "iterator-support.h"
#include "error-tracker.h"
#include "core-types-gen.h"
#include <utility>

static PyMethodDef ChapelMethods[] = {
  { NULL, NULL, 0, NULL } /* Sentinel */
};

static PyModuleDef ChapelModule {
  PyModuleDef_HEAD_INIT,
  .m_name="core",
  .m_doc="A Python bridge for the Chapel frontend library",
  .m_size=-1 /* Per-interpreter memory (not used currently) */,
  .m_methods=ChapelMethods,
};

extern "C" {

PyMODINIT_FUNC PyInit_core() {
  PyObject* chapelModule = nullptr;

  setupAstIterType();
  setupAstCallIterType();
  setupGeneratedTypes();

#define READY_TYPE(NAME) if (PyType_Ready(&NAME##Type) < 0) return nullptr;
#define GENERATED_TYPE(ROOT, NAME, TAG, FLAGS) READY_TYPE(NAME)
#include "generated-types-list.h"
#undef GENERATED_TYPE
  READY_TYPE(AstIter)
  READY_TYPE(AstCallIter)

  if (ContextObject::ready() < 0) return nullptr;
  if (LocationObject::ready() < 0) return nullptr;
  if (ScopeObject::ready() < 0) return nullptr;
  if (AstNodeObject::ready() < 0) return nullptr;
  if (ChapelTypeObject::ready() < 0) return nullptr;
  if (ParamObject::ready() < 0) return nullptr;
  if (ErrorObject::ready() < 0) return nullptr;
  if (ErrorManagerObject::ready() < 0) return nullptr;
  if (ResolvedExpressionObject::ready() < 0) return nullptr;
  if (MostSpecificCandidateObject::ready() < 0) return nullptr;
  if (TypedSignatureObject::ready() < 0) return nullptr;

  chapelModule = PyModule_Create(&ChapelModule);
  if (!chapelModule) return nullptr;

#define ADD_TYPE(NAME) if (PyModule_AddObject(chapelModule, #NAME, (PyObject*) &NAME##Type) < 0) return nullptr;
#define GENERATED_TYPE(ROOT, NAME, TAG, FLAGS) ADD_TYPE(NAME)
#include "generated-types-list.h"
#undef GENERATED_TYPE

  if (ContextObject::addToModule(chapelModule) < 0) return nullptr;
  if (LocationObject::addToModule(chapelModule) < 0) return nullptr;
  if (ScopeObject::addToModule(chapelModule) < 0) return nullptr;
  if (AstNodeObject::addToModule(chapelModule) < 0) return nullptr;
  if (ChapelTypeObject::addToModule(chapelModule) < 0) return nullptr;
  if (ParamObject::addToModule(chapelModule) < 0) return nullptr;
  if (ErrorObject::addToModule(chapelModule) < 0) return nullptr;
  if (ErrorManagerObject::addToModule(chapelModule) < 0) return nullptr;
  if (ResolvedExpressionObject::addToModule(chapelModule) < 0) return nullptr;
  if (MostSpecificCandidateObject::addToModule(chapelModule) < 0) return nullptr;
  if (TypedSignatureObject::addToModule(chapelModule) < 0) return nullptr;

  return chapelModule;
}

}
