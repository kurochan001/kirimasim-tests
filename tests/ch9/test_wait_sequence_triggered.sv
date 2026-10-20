/*
:name: test_wait_sequence_triggered
:description: A wait statement on the triggered method of a named sequence unblocks in the time step in which the sequence reaches its end point, and triggered is false again once time advances (IEEE 1800-2023 Section 9.4.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.4 16.9.11 16.13.6 9.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_sequence_triggered.expected
*/
// IEEE 1800-2023 §9.4.4: wait can delay a process until a named sequence
// reaches its end point, with the sequence method triggered (16.9.11,
// 16.13.6). triggered is set in the Observed region and stays true for the
// rest of the time step. handshake needs req at one rising edge of clk and ack
// at the next: req rises at 12 and ack at 22, so the edges at 15 and 25 match
// and the sequence ends at 25. One time unit later triggered is false.

`timescale 1ns/1ns

module test_wait_sequence_triggered;
  logic clk = 0, req = 0, ack = 0;

  always #5 clk = ~clk;

  sequence handshake;
    @(posedge clk) req ##1 ack;
  endsequence

  initial begin
    #12 req = 1;
    #10 ack = 1;
  end

  initial begin
    wait (handshake.triggered);
    $display("t=%0t: handshake reached its end point", $time);
    #1 $display("t=%0t: triggered=%b", $time, handshake.triggered);
    $finish;
  end
endmodule
