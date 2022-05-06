use GPUDiagnostics;
use Memory.Diagnostics;

writeln("Start");

startVerboseGPU();
startGPUDiagnostics();
startVerboseMem();

var A: [1..10] int = 1;

on here.getChild(1) {
  var AonGPU = A;
  foreach a in AonGPU {
    a += 1;
  }

  A = AonGPU;
}

writeln(A);

stopVerboseMem();
stopGPUDiagnostics();
stopVerboseGPU();

writeln("End");

writeln("GPU diagnostics:");
writeln(getGPUDiagnostics());
