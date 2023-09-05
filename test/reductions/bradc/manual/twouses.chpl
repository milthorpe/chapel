class mysumreduce {
  type t;

  proc ident() {
    return 0;
  }

  proc combine(x: t, y: t): t {
    return x + y;
  }
}

config var n: int = 10;

var D: domain(1) = {1..n};

var A: [D] int;
var B: [D] real;

forall i in D with (ref A, ref B) {
  A(i) = i;
  B(i) = i;
}

{
  var myreduce   = new unmanaged mysumreduce(t = int);
  var state: int = myreduce.ident();

  for i in D {
    state = myreduce.combine(state, A(i));
  }

  var result = state;

  writeln("result is: ", result);

  delete myreduce;
}

{
  var myreduce    = new unmanaged mysumreduce(t = real);
  var state: real = myreduce.ident();

  for i in D {
    state = myreduce.combine(state, B(i));
  }

  var result = state;

  writeln("result is: ", result);

  delete myreduce;
}
