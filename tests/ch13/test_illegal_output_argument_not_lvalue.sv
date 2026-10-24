/*
:name: test_illegal_output_argument_not_lvalue
:description: the actual of an output argument has to be valid on the left of a procedural assignment (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual of the output argument o of the task t is the expression a + b
:expected_stderr_regex: test_illegal_output_argument_not_lvalue\.sv:28:
*/
// IEEE 1800-2023 §13.5: the actual argument of an output or inout argument
// shall be an expression that is valid on the left-hand side of a procedural
// assignment (10.4). The first call passes the variable r, which is legal; the
// second passes a + b, which cannot be assigned.
// Icarus Verilog 13.0 prints a message on this line but completes the
// compilation, and Verilator 5.052 accepts the design.

module test_illegal_output_argument_not_lvalue;
  int a = 1, b = 2, r;
  task t(input int i, output int o);
    o = i * 2;
  endtask
  initial begin
    t(a, r);
    t(a, a + b);   // illegal
  end
endmodule
