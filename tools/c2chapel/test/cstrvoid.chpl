// Generated with c2chapel version 0.1.0

// Header given to c2chapel:
require "cstrvoid.h";

// Note: Generated with fake std headers

use CTypes;
extern proc arg_c_string(str : c_string, n : c_int) : void;

extern proc arg_c_ptr_void(ptr : c_ptr(void)) : void;

extern proc ret_cstr() : c_string;

extern proc ret_void_ptr() : c_ptr(void);

extern proc arg_ptr_to_cstr(ref out_arg : c_string) : void;

extern proc arg_ptr_to_cstr(out_arg : c_ptr(c_string)) : void;

extern proc arg_ptr_to_void_ptr(ref out_arg : c_ptr(void)) : void;

extern proc arg_ptr_to_void_ptr(out_arg : c_ptr(c_ptr(void))) : void;

