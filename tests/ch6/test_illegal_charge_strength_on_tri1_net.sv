/*
:name: test_illegal_charge_strength_on_tri1_net
:description: A charge strength in the declaration of a tri1 net is rejected (IEEE 1800-2023 Section 6.3.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.3.2 6.3.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the tri1 net is declared with a charge strength, which only a trireg net can have
:expected_stderr_regex: test_illegal_charge_strength_on_tri1_net\.sv:24:
*/
// IEEE 1800-2023 §6.3.2 and §6.3.2.1: a charge strength (small, medium or
// large) shall only be used in the declaration of a trireg net. A drive
// strength with a continuous assignment on a tri1 net is legal; on the
// marked line the tri1 net is declared with the charge strength
// (small), an error. Verilator 5.052 rejects every charge strength, also
// on a trireg net, so its error is not this rule. The tests of the other
// net kinds check the same rule.

module test_illegal_charge_strength_on_tri1_net;
  tri1 (strong0, strong1) driven = 1'b1;
  tri1 (small) stored;   // illegal: charge strength on a tri1 net

  assign stored = 1'b0;

  initial #1 $display("%b %b", driven, stored);
endmodule
