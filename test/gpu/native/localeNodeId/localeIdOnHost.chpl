use BlockDist;

const Space = {1..8, 1..8};
const D: domain(2) dmapped blockDist(boundingBox=Space) = Space;
var A: [D] int;

forall a in A do
  a = a.locale.id;

writeln(A);
