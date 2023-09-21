extern record R {
  var a,b,c,d,e,f,g,h,i,j,k: int(64);
  proc init() {
    writeln("In R.init");
    this.a = 1;
    this.b = 2;
    this.c = 3;
    this.d = 4;
    this.e = 5;
    this.f = 6;
    this.g = 7;
    this.h = 8;
    this.i = 9;
    this.j = 0;
    this.k = 1;
    init this;
  }
}

proc printR(r:R) {
  writeln(r.a, r.b, r.c, r.d, r.e, r.f, r.g, r.h, r.i, r.j, r.k);
}

proc testMystruct() {
  writeln("testMystruct");
  var st: R;
  printR(st);
}
testMystruct();
