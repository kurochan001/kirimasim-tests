/*
:name: test_illegal_iterator_argument_without_with
:description: An array method cannot name its iterator without a with clause (IEEE 1800-2023 Section 7.12)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12 7.12.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an array reduction method names an iterator but has no with clause
:expected_stderr_regex: test_illegal_iterator_argument_without_with\.sv:25:
*/
// IEEE 1800-2023 §7.12: the iterator argument of an array method names the
// variable of its with expression, and specifying it without a with clause
// shall be illegal; sum (§7.12.3) is called with an iterator and no with.
// Icarus Verilog 13.0 does not support sum on a queue, so the error it reports
// on that line does not count. Verilator 5.052 stops there because it does not
// find v, which does not show that it knows the rule.

module test_illegal_iterator_argument_without_with;
  int q[$] = '{1, 2, 3};
  int s;
  initial begin
    s = q.sum(v);   // illegal: iterator without with
    $display("s=%0d", s);
  end
endmodule
