// Confirm that it is possible to create two instances of a generic
// class if the class has multiple generic fields.  Until 08/03/2017
// this only worked for one generic field.

class Foo {
  type t1;
  type t2;

  var  x1: t1;
  var  x2: t2;

  proc init(type t1Val, type t2Val) {
    t1 = t1Val;
    t2 = t2Val;

  }
}

var ownFoo1 = new owned Foo(int, int);
var foo1 = ownFoo1.borrow();
var ownFoo2 = new owned Foo(int, int);
var foo2 = ownFoo2.borrow();

writeln(foo1.type == foo2.type);
writeln(foo1);
writeln(foo2);
