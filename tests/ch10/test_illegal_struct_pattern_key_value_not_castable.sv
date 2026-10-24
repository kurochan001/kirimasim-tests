/*
:name: test_illegal_struct_pattern_key_value_not_castable
:description: the value given with a member key in a structure assignment pattern has to be castable to the type of that member (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member key h, a class handle, is given the int value 5
:expected_stderr_regex: test_illegal_struct_pattern_key_value_not_castable\.sv:36:
*/
// IEEE 1800-2023 §10.9.2: the value of a member:value item is evaluated as an
// assignment to the named member and shall be castable to its type, or an
// error is generated. 2.5 for the int member a, 1 for the real member r and
// null for the class handle h are castable, which is legal; 5 for h is not.
// Icarus Verilog 13.0 does not support unpacked structures, so its errors do
// not count.
// The 5.052 release of Verilator accepts the design and then writes C++ code
// that does not compile.

class obj_c;
endclass

module test_illegal_struct_pattern_key_value_not_castable;
  typedef struct {
    int a;
    real r;
    obj_c h;
  } mix_t;
  mix_t s;

  initial begin
    s = '{a:2.5, r:1, h:null};
    s = '{a:1, r:2.0, h:5};   // illegal: an int is not castable to the class handle h
    $display("%0d %0.1f", s.a, s.r);
  end
endmodule
