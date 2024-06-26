config const iters = 300;
config const trials = 2000/here.maxTaskPar;
config const n = 80;

var D: domain(real, parSafe=true);

for i in 1..trials {
  coforall t in 1..n with (ref D) {
    const b = if t & 1 then -1 else 1;
    var r = 1..iters by b;
    for j in r do
      if !D.contains((t+j):real) then
        D += (t+j);
  }
  for j in 2..n+iters do assert(D.contains(j));
  D.clear();
}
