/*
:name: test_illegal_automatic_ref_argument
:description: an attached call in a procedural concurrent assertion passes an automatic variable by reference
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the attached call bump(a) in the automatic task run passes the automatic a to a ref formal
:expected_stderr_regex: test_illegal_automatic_ref_argument\.sv:28:
*/
// IEEE 1800-2023 §16.11, §16.14.6.1: in a subroutine call from an assertion
// statement in procedural code, an automatic variable shall not be passed by
// reference or as a nonconstant input. The assertion in the automatic task
// run passes its automatic input a to the ref formal of bump, so it is
// illegal.

module test_illegal_automatic_ref_argument;
  logic clk = 0;

  task automatic bump(ref int v);
    v = v + 1;
  endtask

  task automatic run(input int a);
    a_bad: assert property (@(posedge clk) (1'b1, bump(a)));   // illegal
  endtask

  initial run(0);
endmodule
