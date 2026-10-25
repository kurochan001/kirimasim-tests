/*
:name: test_illegal_return_outside_subroutine
:description: A return statement outside a task or function is illegal (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a return statement appears in an initial block, which is not a subroutine
:expected_stderr_regex: test_illegal_return_outside_subroutine\.sv:24:
*/
// IEEE 1800-2023 §12.8: the return statement can only be used in a
// subroutine. Here it is in an initial block; the rest is legal.

module test_illegal_return_outside_subroutine;
  int n;

  initial begin
    n = 1;
    if (n == 1) begin
      $display("before");
      return;   // illegal: not inside a task or function
    end
    $display("after");
  end
endmodule
