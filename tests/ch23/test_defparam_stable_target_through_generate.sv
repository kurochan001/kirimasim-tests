/*
:name: test_defparam_stable_target_through_generate
:description: A defparam with a stable target remains legal when its value selects a generate branch (IEEE 1800-2023 Section 23.10.4.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.4.2 23.10.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_stable_target_through_generate.expected
*/
// IEEE 1800-2023 23.10.4.2 23.10.4.1: Elaboration changes generated contents
// but never changes the target parameter name resolution; this complements the
// existing ambiguous-target rejection.

module stable_target #(parameter int P = 1);
  if (P == 5) begin : selected
    localparam int RESULT = 13;
  end else begin : other
    localparam int RESULT = 2;
  end
endmodule
module test_defparam_stable_target_through_generate;
  stable_target u();
  defparam u.P = 5;
  initial $display("parameter=%0d selected=%0d", u.P, u.selected.RESULT);
endmodule
