// This script generates tests for managment casts and coercion. It generates
// all combinations of casts/coercions for flat casts (`MyClass` -> `MyClass`)
// as well as for up and down casts (`ParentClass` and `ChildClass`) using
// `owned`, `shared`, `borrowed`, and `unmanaged`. This is 192 combinations,
// done for explicit casts, coercion by assignment (and initialization), and
// coercion by argument passing (testing all 7 argument intents), for a total
// of 1920 tests.
// The script is run when a `start_test` (or `paratest`) is run on this
// directory by a PRETEST, which generates all the tests This code is
// structured to only output limited sets of tests at a time to support
// breaking them up across directories. For example usage, see
// `explicitCasts/error/PRETEST`.
// Each test classification of cast/coercion (192 tests) is generated by a
// `generateXXX()` function, which defines what is valid with a
// `Set(2*string)`. Each test simply allocates a class and then attempts to
// cast/coerce it to the new type.
use Set;
use IO;
use List;
import FileSystem as FS;
import OS.POSIX as OS;
use CTypes;

// controls whether this generates error test cases or no error test cases
config var generateErrorCases: bool = true;
// controls which suite gets generated
config var generateSuite: string = "explicitCasts";

proc getType(managment, cls) {
  var isNilable = managment.endsWith("?");
  var m = managment.strip("?");
  return "%s %s%s".format(m, cls, if isNilable then "?" else "");
}

proc getAllocationType(managment, cls) {
  var allocation = managment;
  if allocation == "borrowed" then allocation = "owned";
  if allocation == "borrowed?" then allocation = "owned?";

  return getType(allocation, cls);
}

var D = {1..4};
var managmentTypes = ["owned", "shared", "unmanaged", "borrowed"];
var managmentTypesAll: [D.low..D.high*2] string;
managmentTypesAll[D.low..D.high] = managmentTypes;
managmentTypesAll[D.high+1..D.high*2] = ([x in managmentTypes] x + "?");

// generate generic stuff all tests need
proc generateFile(filename: string, const ref lines: list(string)) {
  var chplLines = new list(string);
  chplLines.pushBack("""// AUTO-GENERATED: Do not edit
class A {}
class Parent {}
class Child : Parent {}
""");

  chplLines.pushBack(lines);

  chplLines.pushBack("""proc main() {
  foo();
}
  """);

  {
    var w = openWriter(filename+".chpl");
    for l in chplLines do w.writeln(l);
  }
}
proc generateOneFile(filename: string,
                     const ref lines: list(string),
                     numModules: integral) {
  var chplLines = new list(string);
  chplLines.pushBack("""// AUTO-GENERATED: Do not edit
module %s {
class A {}
class Parent {}
class Child : Parent {}
""".format(filename));

  chplLines.pushBack(lines);

  chplLines.pushBack("proc main() {");
  for i in 1..numModules do
    chplLines.pushBack("  M%n.foo();".format(i));
  chplLines.pushBack("}");
  chplLines.pushBack("}");

  {
    var w = openWriter(filename+".chpl");
    for l in chplLines do w.writeln(l);
  }
}

proc generateFilename(in fromType: string, in toType:string) {
  var fromNilable = fromType.endsWith("?");
  fromType = fromType.strip("?").replace(" ", "-");
  if fromNilable then fromType += "-nilable";
  var toNilable = toType.endsWith("?");
  toType = toType.strip("?").replace(" ", "-");
  if toNilable then toType += "-nilable";

  return "from-%s-to-%s".format(fromType, toType);
}

proc generateDirectoryFiles(errorFiles: bool = true) {
  { openWriter("NOEXEC"); }
  {
    var w = openWriter("all.good");
    if errorFiles
      then w.writeln("Compiler correctly threw an error");
  }
  {
    var w = openWriter("COMPOPTS");
    w.writeln("--permit-unhandled-module-errors --stop-after-pass callDestructors # all.good");
  }
  if errorFiles {
    // runs for any error test case and replaces any output with a fixed message
    const prediff = "PREDIFF";
    var w = openWriter(prediff);
    w.writeln("#!/bin/sh");
    w.writeln("if [ -s $2 ]; then");
    w.writeln("echo 'Compiler correctly threw an error' >$2");
    w.writeln("fi");
    w.close();
    OS.chmod(c_ptrToConst_helper(prediff), 0o755:OS.mode_t);
  }
}



proc generate(allowed: set(2*string),
              allowedUpcast: set(2*string),
              allowedDowncast: set(2*string),
              writeEachTestCase) {

  generateDirectoryFiles(errorFiles = generateErrorCases);

  const legalFileName = "noerror";
  var numLegalModules = 0;
  var legalFileLines = new list(string);


  proc writeTestCase(const ref allowList: set(2*string),
                     from: string,
                     fromClass: string,
                     to: string,
                     toClass: string) {
    const isLegal = allowList.contains((from, to));
    const fromType = getType(from, fromClass);
    const allocFromType = getAllocationType(from, fromClass);
    const toType = getType(to, toClass);
    const allocToType = getAllocationType(to, toClass);

    var chplLines = writeEachTestCase(isLegal, fromType, allocFromType, toType, allocToType);

    var filename = generateFilename(fromType, toType);
    // only generate files when requested to
    if ! isLegal && generateErrorCases
      then generateFile(filename, chplLines);
    if isLegal && ! generateErrorCases {
      numLegalModules += 1;
      legalFileLines.pushBack("module M%n {".format(numLegalModules));
      legalFileLines.pushBack("use noerror;");
      legalFileLines.pushBack(chplLines);
      legalFileLines.pushBack("}");
    }
  }

  for from in managmentTypesAll {
    for to in managmentTypesAll {
      writeTestCase(allowed, from, "A", to, "A");
      writeTestCase(allowedUpcast, from, "Child", to, "Parent");
      writeTestCase(allowedDowncast, from, "Parent", to, "Child");
    }
  }

  if ! generateErrorCases {
    generateOneFile(legalFileName, legalFileLines, numLegalModules);
  }

}




proc generateExplicitCasts() {
  var allowed: set(2*string);
  // cast owned to ...
  for x in ["owned", "borrowed", "owned?", "borrowed?"] do
    allowed.add(("owned", x));

  // cast shared to ...
  for x in ["shared", "borrowed", "shared?", "borrowed?"] do
    allowed.add(("shared", x));

  // cast unmanaged to ...
  for x in ["unmanaged", "borrowed", "unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged", x));

  // cast borrowed to ...
  for x in ["borrowed", "borrowed?"] do
    allowed.add(("borrowed", x));

  // cast owned? to ...
  for x in ["owned", "borrowed", "owned?", "borrowed?"] do
    allowed.add(("owned?", x));

  // cast shared? to ...
  for x in ["shared", "borrowed", "shared?", "borrowed?"] do
    allowed.add(("shared?", x));

  // cast unmanaged? to ...
  for x in ["unmanaged", "borrowed", "unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged?", x));

  // cast borrowed? to ...
  for x in ["borrowed", "borrowed?"] do
    allowed.add(("borrowed?", x));

  // downcast is the same as upcast
  var allowedUpcast: set(2*string);
  for x in allowed do allowedUpcast.add(x);

  // downcast is the same as upcast
  var allowedDowncast: set(2*string);
  for x in allowedUpcast do allowedDowncast.add(x);


  proc writeEachTestCase(isLegal: bool,
                         fromType: string,
                         allocFromType: string,
                         toType: string,
                         allocToType: string): list(string) {
    var chplLines: list(string);

    chplLines.pushBack("proc foo() {");
    chplLines.pushBack("  // casting from %s to %s".format(fromType, toType));
    if allocFromType != fromType {
      chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
      chplLines.pushBack("  var a:%s = alloc;".format(fromType));
    }
    else {
      chplLines.pushBack("  var a = new %s();".format(fromType));
    }
    chplLines.pushBack("  var a_ = a:%s;".format(toType));
    chplLines.pushBack("}");
    return chplLines;
  }
  generate(allowed, allowedUpcast, allowedDowncast, writeEachTestCase);

}






proc generateCoerceInitAndAssign(doInit: bool = true) {

  var allowed: set(2*string);
  // coerce owned to ...
  for x in ["owned", "borrowed", "owned?", "borrowed?"] do
    allowed.add(("owned", x));

  // coerce shared to ...
  for x in ["shared", "borrowed", "shared?", "borrowed?"] do
    allowed.add(("shared", x));

  // coerce unmanaged to ...
  for x in ["unmanaged", "borrowed", "unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged", x));

  // coerce borrowed to ...
  for x in ["borrowed", "borrowed?"] do
    allowed.add(("borrowed", x));

  // coerce owned? to ...
  for x in ["owned?", "borrowed?"] do
    allowed.add(("owned?", x));

  // coerce shared? to ...
  for x in ["shared?", "borrowed?"] do
    allowed.add(("shared?", x));

  // coerce unmanaged? to ...
  for x in ["unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged?", x));

  // coerce borrowed? to ...
  for x in ["borrowed?"] do
    allowed.add(("borrowed?", x));

  // upcast is the same
  var allowedUpcast: set(2*string);
  for x in allowed do allowedUpcast.add(x);

  // downcast is not supported
  var allowedDowncast: set(2*string);


  proc writeEachTestCaseInit(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string) {
    var chplLines: list(string);
    chplLines.pushBack("proc foo() {");
    chplLines.pushBack("  // coercing from %s to %s".format(fromType, toType));
    if allocFromType != fromType {
      chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
      chplLines.pushBack("  var a:%s = alloc;".format(fromType));
    }
    else {
      chplLines.pushBack("  var a = new %s();".format(fromType));
    }
    chplLines.pushBack("  var a_:%s = a;".format(toType));
    chplLines.pushBack("}");
    return chplLines;
  }

  proc writeEachTestCaseAssign(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType:string): list(string) {
    var chplLines: list(string);
    chplLines.pushBack("proc foo() {");
    chplLines.pushBack("  // coercing from %s to %s".format(fromType, toType));
    if allocFromType != fromType {
      chplLines.pushBack("  var allocFrom = new %s();".format(allocFromType));
      chplLines.pushBack("  var a:%s = allocFrom;".format(fromType));
    }
    else {
      chplLines.pushBack("  var a = new %s();".format(fromType));
    }
    if allocToType != toType {
      chplLines.pushBack("  var allocTo = new %s();".format(allocToType));
      chplLines.pushBack("  var a_:%s = allocTo;".format(toType));
    }
    else {
      chplLines.pushBack("  var a_ = new %s();".format(toType));
    }
    chplLines.pushBack("  a_ = a;");
    chplLines.pushBack("}");
    return chplLines;
  }

  var writeFunc = if doInit then writeEachTestCaseInit else writeEachTestCaseAssign;
  generate(allowed, allowedUpcast, allowedDowncast, writeFunc);

}

proc generateArgumentConst() {

  var allowed: set(2*string);
  // coerce owned to ...
  for x in ["owned", "borrowed", "borrowed?"] do
    allowed.add(("owned", x));

  // coerce shared to ...
  for x in ["shared", "borrowed", "borrowed?"] do
    allowed.add(("shared", x));

  // coerce unmanaged to ...
  for x in ["unmanaged", "borrowed", "unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged", x));

  // coerce borrowed to ...
  for x in ["borrowed", "borrowed?"] do
    allowed.add(("borrowed", x));

  // coerce owned? to ...
  for x in ["owned?", "borrowed?"] do
    allowed.add(("owned?", x));

  // coerce shared? to ...
  for x in ["shared?", "borrowed?"] do
    allowed.add(("shared?", x));

  // coerce unmanaged? to ...
  for x in ["unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged?", x));

  // coerce borrowed? to ...
  for x in ["borrowed?"] do
    allowed.add(("borrowed?", x));

  var allowedUpcast: set(2*string);

  // coerce owned to ...
  for x in ["borrowed", "borrowed?"] do
    allowedUpcast.add(("owned", x));
  allowedUpcast.add(("owned?", "borrowed?"));
  // coerce shared to ...
  for x in ["borrowed", "borrowed?"] do
    allowedUpcast.add(("shared", x));
  allowedUpcast.add(("shared?", "borrowed?"));

  // coerce unmanaged to ...
  for x in ["unmanaged", "borrowed", "unmanaged?", "borrowed?"] do
    allowedUpcast.add(("unmanaged", x));
  // coerce borrowed to ...
  for x in ["borrowed", "borrowed?"] do
    allowedUpcast.add(("borrowed", x));
  // coerce unmanaged? to ...
  for x in ["unmanaged?", "borrowed?"] do
    allowedUpcast.add(("unmanaged?", x));
  // coerce borrowed? to ...
  for x in ["borrowed?"] do
    allowedUpcast.add(("borrowed?", x));

  // downcast is not supported
  var allowedDowncast: set(2*string);


  proc writeEachTestCase(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string) {
    var chplLines: list(string);
    chplLines.pushBack("// coercing from %s to %s".format(fromType, toType));
    chplLines.pushBack("proc bar(const x: %s) {}".format(toType));
    chplLines.pushBack("proc foo() {");
    if allocFromType != fromType {
      chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
      chplLines.pushBack("  var a:%s = alloc;".format(fromType));
    }
    else {
      chplLines.pushBack("  var a = new %s();".format(fromType));
    }
    chplLines.pushBack("  bar(a);");
    chplLines.pushBack("}");
    return chplLines;
  }

  generate(allowed, allowedUpcast, allowedDowncast, writeEachTestCase);

}


proc generateArgumentIn(doConst: bool = false) {

  var allowed: set(2*string);
  // coerce owned to ...
  for x in ["owned", "borrowed", "owned?", "borrowed?"] do
    allowed.add(("owned", x));

  // coerce shared to ...
  for x in ["shared", "borrowed", "shared?", "borrowed?"] do
    allowed.add(("shared", x));

  // coerce unmanaged to ...
  for x in ["unmanaged", "borrowed", "unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged", x));

  // coerce borrowed to ...
  for x in ["borrowed", "borrowed?"] do
    allowed.add(("borrowed", x));

  // coerce owned? to ...
  for x in ["owned?", "borrowed?"] do
    allowed.add(("owned?", x));

  // coerce shared? to ...
  for x in ["shared?", "borrowed?"] do
    allowed.add(("shared?", x));

  // coerce unmanaged? to ...
  for x in ["unmanaged?", "borrowed?"] do
    allowed.add(("unmanaged?", x));

  // coerce borrowed? to ...
  for x in ["borrowed?"] do
    allowed.add(("borrowed?", x));

  // upcast is the same
  var allowedUpcast: set(2*string);
  for x in allowed do allowedUpcast.add(x);

  // downcast is not supported
  var allowedDowncast: set(2*string);

  proc writeEachTestCaseHelper(
                     intent: string,
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string) {
      var chplLines: list(string);
      chplLines.pushBack("// coercing from %s to %s".format(fromType, toType));
      chplLines.pushBack("proc bar(%s x: %s) {}".format(intent, toType));
      chplLines.pushBack("proc foo() {");
      if allocFromType != fromType {
        chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
        chplLines.pushBack("  var a:%s = alloc;".format(fromType));
      }
      else {
        chplLines.pushBack("  var a = new %s();".format(fromType));
      }
      chplLines.pushBack("  bar(a);");
      chplLines.pushBack("}");
      return chplLines;
  }


  proc writeEachTestCaseIn(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string)
    do return writeEachTestCaseHelper("in", isLegal, fromType, allocFromType, toType, allocToType);
  proc writeEachTestCaseConstIn(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string)
    do return writeEachTestCaseHelper("const in", isLegal, fromType, allocFromType, toType, allocToType);

  var writeFunc = if doConst then writeEachTestCaseConstIn else writeEachTestCaseIn;
  generate(allowed, allowedUpcast, allowedDowncast, writeFunc);

}

proc generateArgumentRef(doConst: bool = false) {

  var allowed: set(2*string);
  // no change of managment allowed
  for x in managmentTypesAll do allowed.add((x, x));

  // upcast and downcast are not supported
  var allowedUpcast: set(2*string);
  var allowedDowncast: set(2*string);

  proc writeEachTestCaseHelper(
                     intent: string,
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string) {
      var chplLines: list(string);
      chplLines.pushBack("// coercing from %s to %s".format(fromType, toType));
      chplLines.pushBack("proc bar(%s x: %s) {}".format(intent, toType));
      chplLines.pushBack("proc foo() {");
      if allocFromType != fromType {
        chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
        chplLines.pushBack("  var a:%s = alloc;".format(fromType));
      }
      else {
        chplLines.pushBack("  var a = new %s();".format(fromType));
      }
      chplLines.pushBack("  bar(a);");
      chplLines.pushBack("}");
      return chplLines;
  }


  proc writeEachTestCaseRef(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string)
    do return writeEachTestCaseHelper("ref", isLegal, fromType, allocFromType, toType, allocToType);
  proc writeEachTestCaseConstRef(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string)
    do return writeEachTestCaseHelper("const ref", isLegal, fromType, allocFromType, toType, allocToType);

  var writeFunc = if doConst then writeEachTestCaseConstRef else writeEachTestCaseRef;
  generate(allowed, allowedUpcast, allowedDowncast, writeFunc);

}


proc generateArgumentOut() {
  // these are kinda "reversed", since we are assigning to the out variable now
  var allowed: set(2*string);
  allowed.add(("owned", "owned"));
  allowed.add(("owned?", "owned"));
  allowed.add(("owned?", "owned?"));
  allowed.add(("shared", "shared"));
  allowed.add(("shared?", "shared"));
  allowed.add(("shared?", "shared?"));
  allowed.add(("unmanaged", "unmanaged"));
  allowed.add(("unmanaged?", "unmanaged"));
  allowed.add(("unmanaged?", "unmanaged?"));
  allowed.add(("borrowed", "borrowed"));
  allowed.add(("borrowed?", "borrowed"));
  allowed.add(("borrowed?", "borrowed?"));

  allowed.add(("borrowed", "owned"));
  allowed.add(("borrowed", "shared"));
  allowed.add(("borrowed", "unmanaged"));

  allowed.add(("borrowed?", "owned"));
  allowed.add(("borrowed?", "owned?"));
  allowed.add(("borrowed?", "shared"));
  allowed.add(("borrowed?", "shared?"));
  allowed.add(("borrowed?", "unmanaged"));
  allowed.add(("borrowed?", "unmanaged?"));

  // no "upcast", although for out it is backward
  var allowedUpcast: set(2*string);

  // same as allowed
  ref allowedDowncast = allowed;


  proc writeEachTestCase(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string) {
    var chplLines: list(string);
    chplLines.pushBack("// coercing from %s to %s".format(fromType, toType));

    // doing a global alloc to avoid lifetime issues
    if allocToType != toType {
      chplLines.pushBack("var globalAlloc = new %s();".format(allocToType));
    }
    chplLines.pushBack("proc bar(out x: %s) {".format(toType));
    if allocToType != toType {
      chplLines.pushBack("  x = globalAlloc;");
    }
    else {
      chplLines.pushBack("  x = new %s();".format(toType));
    }
    chplLines.pushBack("}");

    chplLines.pushBack("proc foo() {");
    // alloc bere is just a dummy for the non nilable case
    if allocFromType != fromType {
      chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
      chplLines.pushBack("  var a:%s = alloc;".format(fromType));
    }
    else {
      chplLines.pushBack("  var a = new %s();".format(fromType));
    }
    chplLines.pushBack("  bar(a);");
    chplLines.pushBack("}");
    return chplLines;
  }

  generate(allowed, allowedUpcast, allowedDowncast, writeEachTestCase);

}

proc generateArgumentInout() {

  var allowed: set(2*string);
  allowed.add(("owned?", "owned?"));
  allowed.add(("shared", "shared"));
  allowed.add(("shared?", "shared?"));
  allowed.add(("unmanaged?", "unmanaged?"));
  allowed.add(("unmanaged", "unmanaged"));
  allowed.add(("borrowed", "borrowed"));
  allowed.add(("borrowed?", "borrowed?"));
  // upcast and downcast are not supported
  var allowedUpcast: set(2*string);
  var allowedDowncast: set(2*string);


  proc writeEachTestCase(
                     isLegal: bool,
                     fromType: string,
                     allocFromType: string,
                     toType: string,
                     allocToType: string): list(string) {
    var chplLines: list(string);
    chplLines.pushBack("// coercing from %s to %s".format(fromType, toType));

    // doing a global alloc to avoid lifetime issues
    if allocToType != toType {
      chplLines.pushBack("var globalAlloc = new %s();".format(allocToType));
    }
    chplLines.pushBack("proc bar(inout x: %s) {".format(toType));
    if allocToType != toType {
      chplLines.pushBack("  x = globalAlloc;");
    }
    else {
      chplLines.pushBack("  x = new %s();".format(toType));
    }
    chplLines.pushBack("}");

    chplLines.pushBack("proc foo() {");
    if allocFromType != fromType {
      chplLines.pushBack("  var alloc = new %s();".format(allocFromType));
      chplLines.pushBack("  var a:%s = alloc;".format(fromType));
    }
    else {
      chplLines.pushBack("  var a = new %s();".format(fromType));
    }
    chplLines.pushBack("  bar(a);");
    chplLines.pushBack("}");
    return chplLines;
  }

  generate(allowed, allowedUpcast, allowedDowncast, writeEachTestCase);

}


proc main() {

  select(generateSuite) {
    when "explicitCasts" do generateExplicitCasts();
    when "coerceInit" do generateCoerceInitAndAssign(doInit=true);
    when "coerceAssign" do generateCoerceInitAndAssign(doInit=false);
    when "argumentConst" do generateArgumentConst();
    when "argumentConstIn" do generateArgumentIn(doConst=true);
    when "argumentIn" do generateArgumentIn(doConst=false);
    when "argumentConstRef" do generateArgumentRef(doConst=true);
    when "argumentRef" do generateArgumentRef(doConst=false);
    when "argumentOut" do generateArgumentOut();
    when "argumentInout" do generateArgumentInout();
    otherwise do writeln("Unknown suite: ", generateSuite);
  }
}
