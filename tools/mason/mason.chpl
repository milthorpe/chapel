/*
 * Copyright 2020-2021 Hewlett Packard Enterprise Development LP
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
 *
 * Author: Sam Partee
 * Github: @Spartee
 */



use FileSystem;
use Map;
use MasonArgParse;
use MasonBuild;
use MasonDoc;
use MasonEnv;
use MasonExternal;
use MasonHelp;
use MasonInit;
use MasonModify;
use MasonNew;
use MasonPublish;
use MasonRun;
use MasonSearch;
use MasonSystem;
use MasonTest;
use MasonUpdate;
use MasonUtils;
use List;
/*

The Design of Mason
===================

  Mason is a command line tool for building chapel programs to provide users with
       a consistent way of building applications and libraries. Mason uses
       a four state pipeline to go from start to finish in a project. The
       four states are listed below.


  Four States:

  1) Project Code: ``yourProject/src/yourProject.chpl``
           This is the source code of the project the user creates using mason.
  2) Manifest File: ``Mason.toml``
           Toml file containing metadata and dependencies
           Builds dependency directed acyclic graph (DAG) to be
           serialized into lock file
  3) Lock File:  ``Mason.lock``
           Contains necessary build information
           Serialized directed acyclic graph of the dependencies build options
           from the manifest
  4) Dependency Code:  ``$MASON_HOME/src``
           Local dependencies downloaded by mason after the user lists them in
           a project manifest.

Full documentation is located in the chapel release in $CHPL_HOME/doc/rst/tools/mason/mason.rst

*/




proc main(args: [] string) throws {

  var parser = new argumentParser();

  var subCmds = new map(string, shared Argument);

  // define all the supported subcommand strings here
  var cmds = ["add","build","clean","doc","env","external","init","publish",
              "new","rm","run","search","system","test","update",
              "help","version"];
  for cmd in cmds {
    subCmds.add(cmd,parser.addSubCommand(cmd));
  }

  // TODO: remove this once help is automatically generated by argument parser
  var helpFlag = parser.addFlag(name="helpFlag",
                                opts=["-h","--help"],
                                flagInversion=false,
                                defaultValue=false);
  var versionFlag = parser.addFlag(name="versionFlag",
                                   opts=["-V","--version"],
                                   flagInversion=false,
                                   defaultValue=false);
  try {
    parser.parseArgs(args);
  }
  catch ex : ArgumentError {
    stderr.writeln(ex.message());
    masonHelp();
    exit(1);
  }
  // TODO: Can masonHelp take an exit code and do this itself?
  if helpFlag.valueAsBool() {
    masonHelp();
    exit(0);
  }
  // TODO: Can printVersion take an exit code, similar to masonHelp TODO
  if versionFlag.valueAsBool() {
    printVersion();
    exit(0);
  }
  var usedCmd:string;
  var cmdList:list(string);
  // identify which, if any, subcommand was used and collect its arguments
  for (cmd, arg) in subCmds.items() {
    if arg.hasValue() {
      usedCmd = cmd;
      cmdList = new list(arg.values());
      break;
    }
  }
  var cmdArgs = cmdList.toArray();
  // pass the arguments to the appropriate subcommand
  // currently, only add and rm have the new argument parser implemented,
  // so that is why other commands take the full, original, input args
  // while add and rm are taking just the args from the subcommand onward
  try {
    select (usedCmd) {
      when "new" do masonNew(args);
      when "init" do masonInit(args);
      when "add" do masonModify(cmdArgs);
      when "rm" do masonModify(cmdArgs);
      when "build" do masonBuild(args);
      when "update" do masonUpdate(args);
      when "run" do masonRun(args);
      when "search" do masonSearch(args);
      when "system" do masonSystem(args);
      when "external" do masonExternal(args);
      when "test" do masonTest(args);
      when "env" do masonEnv(args);
      when "doc" do masonDoc(args);
      when "publish" do masonPublish(args);
      when "clean" do masonClean(args);
      when "help" do masonHelp();
      when "version" do printVersion();
      otherwise {
        throw new owned MasonError("No such subcommand \ntry mason --help");
        exit(1);
      }
    }
  }
  catch ex : MasonError {
    stderr.writeln(ex.message());
    exit(1);
  }
}


proc masonClean(args) {
  try! {
    if args.size == 3 {
      masonCleanHelp();
      exit(0);
    }
    const cwd = here.cwd();

    const projectHome = getProjectHome(cwd);
    runCommand("rm -rf " + projectHome + "/target");
  }
  catch e: MasonError {
    stderr.writeln(e.message());
  }
}


proc printVersion() {
  writeln("mason 0.1.2");
}
