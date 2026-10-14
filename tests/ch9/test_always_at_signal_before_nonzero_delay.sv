/*
:name: test_always_at_signal_before_nonzero_delay
:description: An always procedure with @(signal) wakes on each change and updates its output before a later delay ends
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2 9.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_at_signal_before_nonzero_delay.expected
*/
`timescale 1ns/1ps

module test;
  bit clk = 0;
  logic [7:0] in;
  logic [7:0] out;

  always #5 clk = ~clk;

  always @(in) begin
    out = in ^ 8'hff;
  end

  initial begin
    #1;  // let the always procedure reach @(in) first (4.7, 9.4.2)
    in = 8'h00;
    #1;
    if (out !== 8'hff) begin
      $display("TEST FAILED: initial always @ update out=%h", out);
      $fatal(1);
    end

    @(posedge clk);
    in = 8'ha5;
    #1;
    if (out !== 8'h5a) begin
      $display("TEST FAILED: always @ update not seen after the delay out=%h", out);
      $fatal(1);
    end

    $display("TEST PASSED: always @ signal update settled before nonzero delay");
    $finish;
  end
endmodule
