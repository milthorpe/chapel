// Test no value capturing in a coforall with a ref clause.

#include "support-decls.cpp"

/////////////////////////////////////////////////////////////////////////////
writeln("=== at the module level ===");
#include "no-capture-coforall.cpp"

/////////////////////////////////////////////////////////////////////////////
writeln("=== in a function ===");
proc test() {
#include "no-capture-coforall.cpp"
}
test();

/////////////////////////////////////////////////////////////////////////////
writeln("=== in a begin ===");
var sbegin: sync int;
begin {
#include "no-capture-coforall.cpp"
  sbegin = 1;
}
sbegin;

/////////////////////////////////////////////////////////////////////////////
writeln("=== in a cobegin ===");
cobegin {
  var iiiii: int;
  {
#include "no-capture-coforall.cpp"
  }
}

/////////////////////////////////////////////////////////////////////////////
writeln("=== in a coforall ===");
coforall iiiii in 1..3 {
  if iiiii == 2 {
#include "no-capture-coforall.cpp"
  }
}

/////////////////////////////////////////////////////////////////////////////
writeln("=== done ===");
