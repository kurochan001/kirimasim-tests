/*
:name: test_illegal_ref_combined_with_output
:description: A formal argument cannot be declared with both ref and output (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a task formal combines ref with the output direction
:expected_stderr_regex: test_illegal_ref_combined_with_output\.sv:26:
*/
// IEEE 1800-2023 §13.5.2: ref is a qualifier of its own, different from
// input, output and inout, and combining ref with any other direction shall
// be illegal. The formal of put is declared with both ref and output; the task
// with a plain ref formal is legal.

module test_illegal_ref_combined_with_output;
  int x;

  task automatic bump(ref int a);
    a = a + 1;
  endtask

  task automatic put(ref output int a);   // illegal: ref combined with output
    a = 5;
  endtask

  initial begin
    x = 0;
    bump(x);
    put(x);
    $display("%0d", x);
  end
endmodule
