/*
:name: test_vpi_assertion_control_rejects_property_and_sequence_instance_handles
:description: Per-assertion control accepts statement handles and rejects their property or sequence operands
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2 38.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_control_rejects_property_and_sequence_instance_handles.expected
:vpi_c: @test_vpi_assertion_property_and_sequence_routes_match_scope_iteration.c
*/
`timescale 1ns/1ns
module test_vpi_assertion_control_rejects_property_and_sequence_instance_handles;
  bit clk;
  int pass_count = 0, cover_count = 0;

  sequence one_match;
    1'b1;
  endsequence

  property one_pass;
    @(posedge clk) 1'b1;
  endproperty

  asserted: assert property (one_pass) pass_count++;
  observed_sequence: cover sequence (@(posedge clk) one_match) cover_count++;

  initial begin
    #1 $vt_control_targets(0);
    #4 clk = 1;
    #1 $display("after operand control pass=%0d cover=%0d", pass_count, cover_count);
    #2 $vt_control_targets(1);
    #2 clk = 0;
    #5 clk = 1;
    #1 $display("after statement control pass=%0d cover=%0d", pass_count, cover_count);
  end
endmodule
