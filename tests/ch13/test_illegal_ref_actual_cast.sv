/*
:name: test_illegal_ref_actual_cast
:description: The actual argument of a ref formal cannot be a cast to the formal's type (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a cast expression is passed to a ref formal
:expected_stderr_regex: test_illegal_ref_actual_cast\.sv:33:
*/
// IEEE 1800-2023 §13.5.2: an argument passed by reference shall be matched
// with an equivalent data type, and no casting shall be permitted. The
// actual here is a cast of a shortint variable to int; the call with an int
// variable is legal.
// Icarus Verilog 13.0 does not support ref formals at all, so its
// rejection does not count.

module test_illegal_ref_actual_cast;
  int i;
  shortint s;

  task automatic bump(ref int a);
    a = a + 1;
  endtask

  initial begin
    i = 0;
    s = 0;
    bump(i);
    bump(int'(s));   // illegal: a cast as the actual of a ref formal
    $display("%0d %0d", i, s);
  end
endmodule
