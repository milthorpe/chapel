var chplInt: int;
var chplReal: real;

export proc chpl_library_init_ftn() {

use CTypes;

  extern proc chpl_library_init(argc: c_int, argv: c_ptr(c_ptr(c_char)));
  var filename = "fake":c_ptrConst(c_char);;
  chpl_library_init(1, c_ptrTo(filename): c_ptr(c_ptr(c_char)));
  chpl__init_chapelProcs();
}

export proc setint(i: int) {
  writeln("in setint, i = ", i);
  chplInt = i;
}

export proc setreal(r: real) {
  writeln("in setreal, r = ", r);
  chplReal = r;
}

export proc getint(): int {
  writeln("in getint, chplInt = ", chplInt);
  return chplInt;
}

export proc getreal(): real {
  writeln("in getreal, chplReal = ", chplReal);
  return chplReal;
}
