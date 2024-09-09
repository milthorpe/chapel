/*
 * Copyright 2020-2024 Hewlett Packard Enterprise Development LP
 * Copyright 2004-2019 Cray Inc.
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/*
Description:

This script analyzes the output generated by your program and provides a
comprehensive summary of different types of unstable warnings without
revealing any implementation details about the program.
It helps us understand the distribution of unstable warnings in your program,
enabling us to identify and prioritize the most common types of unstable
features.


COMPILE: chpl unstableAnonScript.chpl
USAGE: unstableAnonScript [-h, --help] [-c, --csv] [-n, --numFiles] [-d, --sorted] [-i, --inputFiles <INPUTFILE> ...] [-o, --outputFile <OUTPUTFILE>] [-x, --topX <TOPX>]

OPTIONS:
  -h, --help                    Display this message and exit
  -c, --csv                     Write the output in csv format.
                                Defaults to false, which writes in a pretty format
  -i, --inputFiles <INPUTFILE>  The files containing the warnings. Defaults to stdin
  -n, --numFiles                Show the number of unique chapel files that had each warning.
                                Defaults to false
  -o, --outputFile <OUTPUTFILE> The file to write the output to. Defaults to stdout
  -d, --sorted                  Sort the output by descending frequency of each warning.
                                Defaults to false, which sorts by the warning message
  -x, --topX <TOPX>             Show the top X most frequent warnings. Implies --sorted.
                                Defaults to showing all warnings.
                                In case of a tie for the last place, the warning that comes first in the sorted list is chosen



Example Usage:
./unstableAnonScript < warnings.txt > output.txt
./unstableAnonScript -i warnings.txt -o output.txt       # Equivalent to above
./unstableAnonScript -i sample.warnings sample.bad       # Can specify multiple inputFiles at once
./unstableAnonScript -i sample.warnings  --csv           # Can print in csv
./unstableAnonScript -i sample.warnings  --sorted        # Sort by descending frequency of warnings
./unstableAnonScript -i sample.warnings  --numFiles      # Show how many files had each warning
./unstableAnonScript -i sample.warnings  -x 10 -d -c -n  # Any combination of flags
*/

import IO;
import Map.map as map;
import Set.set;
import Sort;
import Regex.regex;
import ArgumentParser;
use Sort only relativeComparator, keyComparator;

proc countUniqueWarnings(ref warningsMap: map(string, ?t),
                         inputFileReader: IO.fileReader(?)
                        ) where t == (int, set(string)) {
  // A pattern of a typical warning line
  // filename.chpl:lineNumber: warning message blah
  // Other warnings looks like this:
  // <command-line arg>:argNumber: warning message blah
  // <command line>: warning message blah
  // Anything inside ( ) is a capture group
  // (?: ) is a non-capturing group
  param regexStr = "(?:(.*\\.chpl|<command-line arg>):\\d+|(<command line>))" +
                   ": (.*)\n"; // The warning message capture group
  const warningRegex = new regex(regexStr);
  var warning: string;
  var fileName: string;
  // Although there are 3 capture groups in the regex,
  // capture group 1 and 2 are mutually exclusive due to the OR operator
  for (_, fileNameMatch, cmdLineMatch, warningMatch)
   in inputFileReader.matches(warningRegex,captures=3) {
    var cmdLine: string;
    inputFileReader.extractMatch(fileNameMatch, fileName);
    inputFileReader.extractMatch(cmdLineMatch, cmdLine);
    inputFileReader.extractMatch(warningMatch, warning);
    fileName+=cmdLine; // Since either fileName or cmdLine will be empty
    // Collapse <command-line arg> and <command line> into <command line>
    // Since they are the same "fileName" (i.e. the command line)
    if fileName == "<command line>" then fileName = "<commond-line arg>";
    // Check if the string mentions that something is unstable
    // If so, add it to the map
    if !containsUnstableWarning(warning) then
      continue;
    warning = anonymizeWarning(warning);
    if warningsMap.contains(warning) {
      warningsMap[warning][0] += 1;
    } else {
      warningsMap[warning][0] = 1;
    }
    // Add the fileName to the set of files that have this warning
    warningsMap[warning][1].add(fileName);
  }
}

proc containsUnstableWarning(warning: string): bool {
  // Check if the string mentions that something is unstable
  return warning.find("unstable") != -1 ||
         warning.find("enum-to-bool") != -1 ||
         warning.find("enum-to-float") != -1;
}


proc anonymizeWarning(warning: string): string {
  // Anonymize known warning messages that include variable names
  // when so that it doesn't reveal variable names or other impl details

  param typeName = "warning: using a type's name ";
  param typeNameUse = "in a 'use' statement to access its tertiary methods " +
                      "is an unstable feature";
  param typeNameImport = "in an 'import' statement to access its tertiary " +
                         "methods is an unstable feature";
  if warning.find(typeName) != 1 {
    if warning.find(typeNameUse) != -1 then
      return typeName + typeNameUse;
    else if warning.find(typeNameImport) != -1 then
      return typeName + typeNameImport;
  }

  param underscore = "warning: symbol names with leading underscores";
  param end = " are unstable";
  if warning.find(underscore) != -1 && warning.find(end) != -1 then
    return underscore + end;

  param chplPrefix = "warning: symbol names beginning with 'chpl_' ";
  if warning.find(chplPrefix) != -1 && warning.find(end) != -1 then
    return chplPrefix + end;

  param pragmas = "uses pragmas, which are considered unstable and may " +
                  "change in the future";
  if warning.find(pragmas) != -1 then
    return "warning: <proc> " + pragmas;

  param constArgs = "was modified indirectly during this function, this " +
                    "behavior is unstable and may change in the future.";
  if warning.find(constArgs) != -1 then
    return "warning: The argument " + constArgs;

  param ambigSourceNote = "which module is chosen in this case is unstable";
  param ambigSource = "warning: ambiguous module source file; ";
  if warning.find(ambigSourceNote) != -1 then
    return ambigSource + ambigSourceNote;

  return warning;
}

inline proc prettyPrintArr(arr: [] (string, int, int),
                           writer: IO.fileWriter(?), fileCount: bool) {
  for a in arr {
    const grammar = if a[1] < 2 then " instance of \"" else " instances of \"";
    const files;
    if fileCount {
      const plurality = if a[2] < 2 then " file" else " files";
      files = "\" across " + a[2]:string + plurality;
    } else files = "\"";
    writer.writeln(a[1], grammar, a[0], files);
  }
}


inline proc csvPrintArr(arr: [] (string, int, int),
                        writer: IO.fileWriter(?),
                        fileCount: bool){
  writer.writeln("warning", ",", "count",
                 if fileCount then ",uniqueFiles" else "");
  for a in arr {
    const files = if fileCount then "," + a[2]:string else "";
    writer.writeln("\"", a[0], "\"", ",", a[1], files);
  }
}

// Comparator to sort our array representation of the map
// by the number of occurrences of each warning
record occurrenceComparator: relativeComparator {}
proc occurrenceComparator.compare(a: (string, int, int), b: (string, int, int)){
  return b[1] - a[1];  // Reverse sort
}

record warningComparator: keyComparator {}
proc warningComparator.key(a: (string, int, int)) { return a[0]; }

proc convertMapToArray(const m: map(string, ?t), sorted: bool, topX: int)
                       where t == (int, set(string)) {
  var arr: [0..<m.size] (string, int, int);
  for (a, key) in zip(arr,m.keys()) {
    // We don't need to save the entire list
    // of fileNames at this point, just the size is enough
    a = (key, m[key][0], m[key][1].size);
  }
  if sorted {
    var comp: occurrenceComparator;
    Sort.sort(arr, comparator=comp);
  } else {
    var comp: warningComparator;
    Sort.sort(arr, comparator=comp);
  }
  if topX > 0 && arr.size > topX then
    return arr[0..<topX];
  return arr;
}



proc main(args: []string) throws {

  var parser = new ArgumentParser.argumentParser();
  param csvArgMsg =  "Write the output in csv format. " +
                     "Defaults to false, which writes in a pretty format";
  param sortArgMsg = "Sort the output by descending frequency of each "+
                     "warning. " +
                     "Defaults to false, which sorts by the warning message";
  param numFilesArgMsg = "Show the number of unique chapel files " +
                         "that had each warning. Defaults to false";
  param inputFilesArgMsg = "The files containing the warnings. " +
                           "Defaults to stdin";
  param outputFileArgMsg = "The file to write the output to. " +
                           "Defaults to stdout";
  param topXArgHelpMsg =  "Show the top X most frequent warnings. " +
                          "Implies --sorted. Defaults to showing all warnings.\
                            In case of a tie for the last place, " +
                           "the warning that comes first in the " +
                           "sorted list is chosen";
  var csvArg = parser.addFlag(name="csv", defaultValue=false,
                            opts = ["-c", "--csv"],
                            help=csvArgMsg);
  var numFilesArg = parser.addFlag(name="numFiles", defaultValue=false,
                            opts = ["-n", "--numFiles"],
                            help=numFilesArgMsg);
  var sortArg = parser.addFlag(name="sorted", defaultValue=false,
                            opts = ["-d", "--sorted"],
                            // -s is reserved for configs, so we use -d
                            help=sortArgMsg);
  var inputFilesArg = parser.addOption(name="inputFile", numArgs=1..,
                            opts = ["-i", "--inputFiles"],
                            help=inputFilesArgMsg);
  var outputFileArg = parser.addOption(name="outputFile", numArgs=1,
                            opts = ["-o", "--outputFile"],
                            help=outputFileArgMsg);
  var topXArg = parser.addOption(name="topX", numArgs=1,
                            opts = ["-x", "--topX"],
                            help=topXArgHelpMsg);
  parser.parseArgs(args);

  const inputFiles = inputFilesArg.values();
  const outputFile = if outputFileArg.hasValue()
                     then outputFileArg.value() else "";
  const csv = csvArg.valueAsBool();
  const numFiles = numFilesArg.valueAsBool();
  const topX = if topXArg.hasValue() then topXArg.value():int else -1;
  const sorted = sortArg.valueAsBool() || topX > 0;

  var uniqueWarnings = new map(string, (int, set(string)));

  if inputFiles.size > 0 then
    for inputFile in inputFiles {
      var inputFileReader = IO.openReader(inputFile, locking=false);
      countUniqueWarnings(uniqueWarnings, inputFileReader);
    }
  else
    countUniqueWarnings(uniqueWarnings, IO.stdin);

  var warningsArray = convertMapToArray(uniqueWarnings, sorted, topX);

  var outputFileWriter = if outputFile != ""
                          then
                            // locking=true because IO.stdout has locking=true
                            // and the types of the if-else block need to match
                            IO.openWriter(outputFile, locking=true)
                          else
                            IO.stdout;
  if csv then
    csvPrintArr(warningsArray, outputFileWriter, numFiles);
  else
    prettyPrintArr(warningsArray, outputFileWriter, numFiles);
}
