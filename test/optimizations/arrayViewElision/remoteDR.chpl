var A: [1..10] int;

on Locales[1] {
  var B: [1..10] int = 1;

  A[1..5] = B[1..5];

  writeln(A);
}
