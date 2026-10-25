/*
:name: test_illegal_ref_actual_expression
:description: An expression that is not a variable cannot be the actual argument of a ref formal (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the expression i + 1 is passed to a ref formal
:expected_stderr_regex: test_illegal_ref_actual_expression\.sv:33:
*/
// IEEE 1800-2023 §13.5.2: only a variable, a class property, a member of an
// unpacked structure or an element of an unpacked array can be passed by
// reference. The actual here is the expression i + 1, which is none of
// these; the call with the variable i is legal.
// Icarus Verilog 13.0 does not support ref formals at all, and in a run
// with Verilator 5.052 the line is rejected for a type mismatch
// (logic[31:0] for int), not because an expression is passed; neither
// counts.

module test_illegal_ref_actual_expression;
  int i;

  task automatic show(ref int a);
    $display("%0d", a);
  endtask

  initial begin
    i = 4;
    show(i);
    show(i + 1);   // illegal: an expression passed by reference
  end
endmodule
