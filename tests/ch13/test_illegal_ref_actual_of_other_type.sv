/*
:name: test_illegal_ref_actual_of_other_type
:description: The actual argument of a ref formal has to be of an equivalent type: a shortint variable cannot be passed to a ref int formal (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2 6.22.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a shortint variable is passed to a ref formal of type int
:expected_stderr_regex: test_illegal_ref_actual_of_other_type\.sv:33:
*/
// IEEE 1800-2023 §13.5.2: an argument passed by reference shall be matched
// with an equivalent data type (6.22.2). The ref formal is int, and the
// actual is a shortint variable, which is not equivalent to int; the call
// with an int variable is legal.
// Icarus Verilog 13.0 does not support ref formals at all, so its
// rejection does not count.

module test_illegal_ref_actual_of_other_type;
  int i;
  shortint s;

  task automatic bump(ref int a);
    a = a + 1;
  endtask

  initial begin
    i = 0;
    s = 0;
    bump(i);
    bump(s);   // illegal: shortint actual for a ref int formal
    $display("%0d %0d", i, s);
  end
endmodule
