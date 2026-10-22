/*
:name: test_timing_delayed_signals_positive_limits
:description: The delayed reference and data signals named in a $setuphold with positive limits are not delayed, so a flip-flop built on them works as one built on the original signals (IEEE 1800-2023 Section 31.9.1)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_delayed_signals_positive_limits.expected
*/
// IEEE 1800-2023 §31.9.1: a $setuphold (31.3.3) can name delayed copies of its
// reference and data signals, for the functional model to use; they are
// actually delayed only when a limit is negative, and without the invocation
// option for negative checks they are plain copies (31.9.4). Here both limits
// are positive, so dclk and dd follow clk and d at once, and the flip-flop
// that samples dd at the rising edge of dclk stores what d holds at each
// rising edge of clk. d never changes near an edge, so there is no violation.

`timescale 1ns/1ns

module test_timing_delayed_signals_positive_limits_ff(input clk, input d, output reg q);
  wire dclk, dd;
  reg n = 0;

  specify
    $setuphold(posedge clk, d, 3, 2, n, , , dclk, dd);
  endspecify

  always @(posedge dclk) q <= dd;
endmodule

module test_timing_delayed_signals_positive_limits;
  reg clk = 0, d = 1;
  wire q;

  test_timing_delayed_signals_positive_limits_ff u(clk, d, q);

  task show;
    $display("t=%0d clk=%b dclk=%b d=%b dd=%b q=%b n=%b", $time, clk, u.dclk, d, u.dd, q,
             u.n);
  endtask

  initial begin
    #10 clk = 1;
    #2 show;           // 12
    #3 d = 0;
    #2 show;           // 17
    #3 clk = 1'b0;
    #3 clk = 1;        // 23
    #2 show;           // 25
  end
endmodule
