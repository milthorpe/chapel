class LotsOFields {
  var f1: int;
  param f2: real = 14.3;
  const f3 = false;

  proc init(val1, param val2, val3) {
    f1 = val1;
    f2 = val2;
    f3 = val3;
  }
}

proc main() {
  var ownC = new owned LotsOFields(2, 6.3, true);
  var c: borrowed LotsOFields(6.3) = ownC.borrow();

  writeln(c);
}
