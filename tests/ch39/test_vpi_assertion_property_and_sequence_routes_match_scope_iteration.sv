/*
:name: test_vpi_assertion_property_and_sequence_routes_match_scope_iteration
:description: Navigation from assertions and scope iteration reach the same property and sequence declarations
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.3.1 37.50 37.51 37.53
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_property_and_sequence_routes_match_scope_iteration.expected
:vpi_c: @test_vpi_assertion_property_and_sequence_routes_match_scope_iteration.c
*/
`timescale 1ns/1ns
module test_vpi_assertion_property_and_sequence_routes_match_scope_iteration;
  bit clk, val;

  sequence s_span(bit q);
    q ##1 q;
  endsequence

  property p_hold(bit q);
    @(posedge clk) q |=> q;
  endproperty

  asserted: assert property (p_hold(val));
  observed_sequence: cover sequence (@(posedge clk) s_span(val));

  initial #1 $vt_compare_routes;
endmodule
