use BlockDist;
config const N = 500 : int(64);

var Dist = new blockDist(rank=1, idxType=int(64), boundingBox={0..#N});
var Dom : domain(1, int(64)) dmapped Dist = {0..#N};

var U : [Dom] real;
var vv = + reduce [(u,j) in zip(U,0..#N)] (u + u);
writeln(vv);
