/*
:name: test_vpi_scalar_callbacks_keep_high_and_low_strength_states
:description: VPI scalar value reads and value-change callbacks distinguish ambiguous high and low strength states from ordinary unknown
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.15 28.12.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vpi_scalar_callbacks_keep_high_and_low_strength_states.expected
:vpi_c: @test_vpi_scalar_callbacks_keep_high_and_low_strength_states.c
*/
`timescale 1ns/1ns

module test_vpi_scalar_callbacks_keep_high_and_low_strength_states;
  logic source = 0;
  wire high_ambiguous, low_ambiguous, ordinary;
  assign (highz0, strong1) high_ambiguous = source;
  assign (strong0, highz1) low_ambiguous = source;
  assign ordinary = source;

  task automatic observe(input logic value);
    source = value;
    #1;
    $display("strengths=%v %v %v", high_ambiguous, low_ambiguous, ordinary);
    $vt_scalar_snapshot;
  endtask

  initial begin
    #1 $vt_start_scalar_watch;
    #4 observe(1'b1);
    #4 observe(1'bx);
    #4 observe(1'b0);
    #4 observe(1'bz);
    $vt_report_scalar_watch;
  end
endmodule
