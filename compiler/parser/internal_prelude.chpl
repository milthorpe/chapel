class Index {
}

class Array {
  function this(i) {
    return __primitive("array_index", this, i);
  }
  function this(i, j) {
    return __primitive("array_index", this, i, j);
  }
  function this(i, j, k) {
    return __primitive("array_index", this, i, j, k);
  }
}

class Domain {
}

class Tuple {
  function this(i) {
    return __primitive("index_object", this, i);
  }
}

function _chpl_malloc(number, size, description: string);
function _chpl_calloc(number, size, description: string);
function _chpl_free(memory);
function _chpl_realloc(memory, number, size);

function _UNION_CHECK(u, tag, filename, lineno);
function _UNION_SET(u, tag);

function _INIT_CONFIG(v, v_type, chapel_name, module_name);
function _INIT_ARRAY(rank, arr, dom, elt_type);
function _INIT_DOMAIN_DIM(dom, dim, lo, hi, str);
