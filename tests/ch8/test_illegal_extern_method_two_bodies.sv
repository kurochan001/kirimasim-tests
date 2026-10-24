/*
:name: test_illegal_extern_method_two_bodies
:description: an extern method cannot have more than one out-of-block declaration (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the extern method id of twice_c has two out-of-block declarations
:expected_stderr_regex: test_illegal_extern_method_two_bodies\.sv:32:
*/
// IEEE 1800-2023 §8.24: it shall be an error if more than one out-of-block
// declaration is given for an extern method. twice_c::id is declared twice
// out of block; size has one declaration, as required.
// Icarus Verilog 13.0 does not support out-of-block methods.

class twice_c;
  extern function int id();
  extern function int size();
endclass

function int twice_c::size();
  return 8;
endfunction

function int twice_c::id();
  return 1;
endfunction

function int twice_c::id();   // illegal: second out-of-block declaration
  return 2;
endfunction

module test_illegal_extern_method_two_bodies;
  initial $display("done");
endmodule
