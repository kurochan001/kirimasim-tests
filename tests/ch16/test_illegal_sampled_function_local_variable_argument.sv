/*
:name: test_illegal_sampled_function_local_variable_argument
:description: the argument of a sampled value function cannot reference a local variable of an assertion (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument of $past in p_bad is the local variable k
:expected_stderr_regex: test_illegal_sampled_function_local_variable_argument\.sv:30:
*/
// IEEE 1800-2023 §16.9.3: local variables (16.10) and the sequence method
// matched are not allowed in the argument expressions of sampled value
// functions. p_ok compares the local variable k with $past(d), whose
// argument is the module variable d; p_bad passes k to $past.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_sampled_function_local_variable_argument;
  logic clk = 0, a = 0;
  logic [3:0] d = 0;
  property p_ok;
    logic [3:0] k;
    (a, k = d) ##1 (k == $past(d));
  endproperty
  property p_bad;
    logic [3:0] k;
    (a, k = d) ##1 ($past(k) == d);   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule
