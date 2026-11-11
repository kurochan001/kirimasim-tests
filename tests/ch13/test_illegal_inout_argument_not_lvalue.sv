/*
:name: test_illegal_inout_argument_not_lvalue
:description: the actual of an inout argument has to be valid on the left of a procedural assignment (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual of the inout argument io of the function bump is the expression r + 1
:expected_stderr_regex: test_illegal_inout_argument_not_lvalue\.sv:28:
*/
// IEEE 1800-2023 §13.5: the actual argument of an output or inout argument
// shall be an expression that is valid on the left-hand side of a procedural
// assignment (10.4). The first call passes the variable r, which is legal; the
// second passes r + 1, which cannot be assigned.
// Icarus Verilog 13.0 does not support inout arguments of functions, so its
// errors do not count, and Verilator 5.052 accepts the design.

module test_illegal_inout_argument_not_lvalue;
  int r = 1;
  function void bump(inout int io);
    io = io + 1;
  endfunction
  initial begin
    bump(r);
    bump(r + 1);   // illegal
  end
endmodule
