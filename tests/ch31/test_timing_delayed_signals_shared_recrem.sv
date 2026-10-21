/*
:name: test_timing_delayed_signals_shared_recrem
:description: With limits that are not negative, the delayed signals of $recrem and $setuphold checks, a delayed clock among them that three checks share, are plain copies of their signals, so a flip-flop with an asynchronous reset built on them works as one built on the originals (IEEE 1800-2023 Section 31.9.1)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.3.6 31.3.3 31.9.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_delayed_signals_shared_recrem.expected
*/
// IEEE 1800-2023 §31.9.1: $setuphold (31.3.3) and $recrem (31.3.6) can name
// delayed copies of their reference and data signals for the functional
// model, and a signal has one delayed signal, even when several checks name
// it: here dclk is the delayed clock of the two $setuphold checks, where the
// clock is the reference, and of the $recrem check, where it is the data
// signal. The delayed signals are actually delayed only when a limit is
// negative; all limits here are positive, so dclk, drst_n, dd1 and dd2
// follow their signals at once (as they also do without the option for
// negative checks, 31.9.4). The flip-flop on them is cleared when rst_n
// falls at 2, loads d1 and d2 at the rising edges of clk at 10 and 20, after
// the release of rst_n at 5, and is cleared again when rst_n falls at 24.
// No signal changes inside a window, so the notifier stays 0.

`timescale 1ns/1ns

module test_timing_delayed_signals_shared_recrem_ff (input clk, input rst_n, input d1,
                                                     input d2, output reg q1, output reg q2);
  wire dclk, drst_n, dd1, dd2;
  reg n = 0;

  specify
    $setuphold(posedge clk, d1, 2, 1, n, , , dclk, dd1);
    $setuphold(posedge clk, d2, 3, 1, n, , , dclk, dd2);
    $recrem(posedge rst_n, posedge clk, 2, 1, n, , , drst_n, dclk);
  endspecify

  always @(posedge dclk or negedge drst_n)
    if (!drst_n) begin
      q1 <= 0;
      q2 <= 0;
    end else begin
      q1 <= dd1;
      q2 <= dd2;
    end
endmodule

module test_timing_delayed_signals_shared_recrem;
  reg clk = 0, rst_n = 1, d1 = 1, d2 = 0;
  wire q1, q2;

  test_timing_delayed_signals_shared_recrem_ff u(clk, rst_n, d1, d2, q1, q2);

  task show;
    $display("t=%0t clk=%b dclk=%b rst_n=%b drst_n=%b d1=%b dd1=%b d2=%b dd2=%b q=%b%b n=%b",
             $time, clk, u.dclk, rst_n, u.drst_n, d1, u.dd1, d2, u.dd2, q1, q2, u.n);
  endtask

  initial begin
    #2 rst_n = 0;
    #3 rst_n = 1;       // 5
    #1 show;            // 6
    #4 clk = 1;         // 10
    #2 show;            // 12
    #2 d1 = 0;          // 14
    d2 = 1;
    #1 clk = 0;         // 15
    #1 show;            // 16
    #4 clk = 1;         // 20
    #2 show;            // 22
    #2 rst_n = 0;       // 24
    #1 show;            // 25
  end
endmodule
