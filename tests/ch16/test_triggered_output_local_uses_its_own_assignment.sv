/*
:name: test_triggered_output_local_uses_its_own_assignment
:description: Triggered uses the output local assigned by its operand sequence
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_triggered_output_local_uses_its_own_assignment.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_triggered_output_local_uses_its_own_assignment;
  bit clock, start_parent, direct_arm, direct_done, triggered_arm, triggered_done;
  int payload_direct, payload_triggered;
  int captured_direct, captured_triggered, direct_hits, triggered_hits;

  always #5 clock = ~clock;

  function automatic void record_direct(int value);
    captured_direct = value;
    direct_hits++;
  endfunction

  function automatic void record_triggered(int value);
    captured_triggered = value;
    triggered_hits++;
  endfunction

  sequence read_then_write(local inout int captured);
    @(posedge clock) (direct_arm && captured == 77, captured = payload_direct)
      ##1 direct_done;
  endsequence

  sequence write_then_read(local output int captured);
    @(posedge clock) (triggered_arm, captured = payload_triggered)
      ##1 (triggered_done && captured == 29);
  endsequence

  sequence use_inout_directly;
    int captured;
    @(posedge clock) (start_parent, captured = 77)
      ##1 read_then_write(captured) ##1 (1'b1, record_direct(captured));
  endsequence

  sequence use_inout_through_triggered;
    int captured;
    @(posedge clock) (start_parent, captured = 77)
      ##1 write_then_read(captured).triggered ##1 (1'b1, record_triggered(captured));
  endsequence

  direct_match: cover sequence (use_inout_directly);
  triggered_match: cover sequence (use_inout_through_triggered);

  initial begin
    #2;
    start_parent = 1;
    triggered_arm = 1;
    payload_triggered = 29;
    #6;
    start_parent = 0;
    triggered_arm = 0;
    triggered_done = 1;
    payload_triggered = 42;
    #4;
    direct_arm = 1;
    payload_direct = 51;
    #7;
    triggered_done = 0;
    direct_arm = 0;
    direct_done = 1;
    #10 direct_done = 0;
    #11;
    $display("direct=%0d hits=%0d triggered=%0d hits=%0d",
             captured_direct, direct_hits, captured_triggered, triggered_hits);
    $finish(0);
  end
endmodule
