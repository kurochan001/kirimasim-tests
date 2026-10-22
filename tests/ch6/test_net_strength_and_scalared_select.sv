/*
:name: test_net_strength_and_scalared_select
:description: Scalared net part selects resolve asymmetric driver strengths independently (IEEE 1800-2023 Section 6.3.2.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.2.2 6.9.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_strength_and_scalared_select.expected
*/
// IEEE 1800-2023 6.3.2.2 6.9.2: A stronger zero defeats a weaker one per bit;
// undriven scalared bits and selected driven bits remain independently
// accessible.
// Oracle checks: The 5.052 release does not build this case.

module test_net_strength_and_scalared_select;
  wire scalared [1:0] bus;
  assign (strong0, weak1) bus = 2'b01;
  assign (pull0, pull1) bus = 2'b10;
  initial #1 $display("resolved=%b low=%b high=%b", bus, bus[0], bus[1]);
endmodule
