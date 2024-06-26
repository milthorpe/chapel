class C {
  var n: int;
  var A: [1..n] int;

  iter these() ref {
    for e in A do
      yield e;
  }

  iter these(param tag: iterKind) where tag == iterKind.leader {
    writeln("leader method invoked");
    cobegin {
      yield 1..n/2;
      yield n/2+1..n;
    }
  }

  iter these(param tag: iterKind, followThis) ref where tag == iterKind.follower {
    for i in followThis do
      yield A(i);
  }
}

var ownC = new owned C(12);
var c = ownC.borrow();

writeln(c);

for e in c do
  e = 1;

writeln(c);

forall e in c do
  e = 2;

writeln(c);
