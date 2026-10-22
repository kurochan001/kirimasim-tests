/*
:name: test_nonresistive_pass_preserves_pull_strength
:description: Nonresistive pass devices preserve pull strength and reduce supply strength to strong (IEEE 1800-2023 Section 28.13)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonresistive_pass_preserves_pull_strength.expected
*/
// IEEE 1800-2023 28.13: Two separate pass paths distinguish supply reduction
// from preservation of ordinary non-supply strengths.
// Oracle checks: The 5.052 release does not build this case.

module test_nonresistive_pass_preserves_pull_strength;
  supply1 source_supply;
  wire source_pull, from_supply, from_pull;
  assign (pull0, pull1) source_pull = 1'b1;
  tran first(from_supply, source_supply);
  tran second(from_pull, source_pull);
  initial #1 $display("supply_path=%v pull_path=%v", from_supply, from_pull);
endmodule
