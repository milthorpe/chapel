use OS.POSIX;
// Test the correctness of changing the mode of files and directories.  Assumes
// that the process umask is 0022.  Note: will break if umask is different.
config const permissions = 0o777: c_int;
var filename = c_ptrToConst_helper("file");
var dirname = c_ptrToConst_helper("dir");
chmod(filename, permissions: mode_t);
chmod(dirname, permissions: mode_t);
