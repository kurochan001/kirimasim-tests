/*
:name: test_vpi_assertion_start_occurs_only_for_evaluated_instances
:description: Start callbacks follow each evaluation of a property or sequence in a verification statement and never occur for unused declarations
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 39.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_start_occurs_only_for_evaluated_instances.expected
:vpi_c: @test_vpi_assertion_start_occurs_only_for_evaluated_instances.c
*/
`timescale 1ns/1ns

module test_vpi_assertion_start_occurs_only_for_evaluated_instances;
  logic clk = 0;

  property p_live;
    @(posedge clk) 1'b1;
  endproperty

  property p_unused;
    @(posedge clk) 1'b1;
  endproperty

  sequence s_live;
    1'b1 ##1 1'b1;
  endsequence

  sequence s_unused;
    1'b1 ##1 1'b1;
  endsequence

  checked: assert property (p_live);
  covered: cover sequence (@(posedge clk) s_live);

  initial begin
    #1 $vt_watch_start;
    #4 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 $vt_start_report;
    $finish;
  end
endmodule
