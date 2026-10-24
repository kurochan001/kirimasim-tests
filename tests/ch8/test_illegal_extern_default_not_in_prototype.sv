/*
:name: test_illegal_extern_default_not_in_prototype
:description: an out-of-block method declaration cannot add a default argument value that its prototype does not have (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of scale gives a default value to f, which has none in the prototype
:expected_stderr_regex: test_illegal_extern_default_not_in_prototype\.sv:30:
*/
// IEEE 1800-2023 §8.24: if an out-of-block declaration gives a default
// argument value, the prototype shall give a syntactically identical one;
// so an out-of-block declaration cannot add a default. lift repeats the
// default of its prototype, which is legal; scale adds one to f.
// Icarus Verilog 13.0 does not support out-of-block methods, and Verilator
// 5.052 accepts the design.

class calc_c;
  extern function int lift(int x, int s = 4);
  extern function int scale(int x, int f);
endclass

function int calc_c::lift(int x, int s = 4);
  return x + s;
endfunction

function int calc_c::scale(int x, int f = 2);   // illegal: default added
  return x * f;
endfunction

module test_illegal_extern_default_not_in_prototype;
  calc_c c = new;
  initial $display("%0d %0d", c.lift(1), c.scale(3, 3));
endmodule
