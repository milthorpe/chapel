use CTypes;
extern proc printf(fmt:c_string, arg:c_string);

var s1 = "0" * 10;
var s2 = "1" * 3;

var test = s1;
test = s2;

printf("%s\n", c_ptrToConst_helper(test):c_string);
