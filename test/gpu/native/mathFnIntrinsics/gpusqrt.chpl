use Random;
use AutoMath;

param N = 1024;
param B = 4;

proc main() {
  on here.gpus[0] {
    var A: [0..<N] real;
    var AA: [0..<N] real;
    fillRandom(A);
    AA = A;

    foreach i in 0..<N / B {
      for param j in 0..<B {
        A[i*B+j] = sqrt(A[i*B+j]);
      }
    }
    for i in 0..<N {
      assert(A[i] == sqrt(AA[i]));
    }
  }
}
