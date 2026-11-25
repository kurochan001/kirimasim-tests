/*
:name: test_sequence_triggered_replaces_ended
:description: Triggered detects a sequence endpoint in a sequence expression
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 C.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_sequence_triggered_replaces_ended
:expected_stdout: @test_sequence_triggered_replaces_ended.expected
*/
`timescale 1ns/1ns
module test_sequence_triggered_replaces_ended;
  logic clk = 0, req = 0, ack = 0, gate = 0;
  int match_count = 0;
  always #5 clk = ~clk;

  sequence request_complete;
    @(posedge clk) req ##1 ack;
  endsequence

  sequence enabled_completion;
`ifdef PROBE_LEGACY_METHOD
    @(posedge clk) request_complete.ended ##0 gate;
`elsif PROBE_UNKNOWN_METHOD
    @(posedge clk) request_complete.no_such_sequence_method ##0 gate;
`else
    @(posedge clk) request_complete.triggered ##0 gate;
`endif
  endsequence

  cover sequence (enabled_completion) begin
    match_count++;
    $display("matched t=%0d", $time);
  end

  initial begin
    #2 req = 1;
    #10 req = 0; ack = 1; gate = 1;
    #10 ack = 0; gate = 0;
    #10 req = 1;
    #10 req = 0; ack = 1;
    #10 ack = 0;
    #2 $display("matches=%0d", match_count);
    $finish(0);
  end
endmodule
