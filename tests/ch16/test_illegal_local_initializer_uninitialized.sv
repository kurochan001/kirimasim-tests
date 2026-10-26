/*
:name: test_illegal_local_initializer_uninitialized
:description: a local variable initializer refers to a previously declared local variable that has no initializer
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initializer of y in p_bad uses x, which has no initialization assignment
:expected_stderr_regex: test_illegal_local_initializer_uninitialized\.sv:24:
*/
// IEEE 1800-2023 §16.10: the initializer of a local variable may refer to a
// previously declared local variable only if that variable itself has an
// initialization assignment. x has none, so the initializer of y in p_bad is
// illegal. The property is otherwise legal.

module test_illegal_local_initializer_uninitialized;
  logic clk = 0, a = 1;

  property p_bad;
    int x;
    int y = x + 1;   // illegal
    @(posedge clk) a;
  endproperty

  a_bad: assert property (p_bad);
endmodule
