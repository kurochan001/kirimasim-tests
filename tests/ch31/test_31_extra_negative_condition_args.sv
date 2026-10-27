/*
:name: test_31_extra_negative_condition_args
:description: A $setuphold with negative limits accepts &&& conditions on both events and the timestamp and timecheck conditions after the notifier, and its delayed reference and data are the named signals (IEEE 1800-2023 Sections 31.9.2 and 31.3.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.2 31.3.3 31.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_31_extra_negative_condition_args.expected
*/
// IEEE 1800-2023 31.9.2: besides the &&& condition of a reference or data
// event, a negative timing check can take a timestamp_condition and a
// timecheck_condition immediately after the notifier, so that each event can
// be conditioned by its role. The cell below gives all nine arguments of
// $setuphold: the two events each with &&& en, the negative setup limit,
// the positive hold limit, the notifier n, the timestamp condition ts, the
// timecheck condition tc, and the delayed reference dclk and delayed data dd.
// The event conditions and the two condition arguments are constants 1 here,
// so the check is enabled for every event. Icarus Verilog 13.0 does not
// perform the check and makes dclk and dd copies of clk and d (31.9.4), which
// the test prints; the flip-flop on the copies then stores d. A parser that
// did not accept a condition argument after the notifier, or an event
// condition together with it, would not build the design.

`timescale 1ns/1ns

module tnc_cell(input wire clk, input wire d, input wire en, input wire ts,
                input wire tc, output reg q = 0);
  wire dclk, dd;
  reg n = 0;

  specify
    $setuphold(posedge clk &&& en, d &&& en, -3, 8, n, ts, tc, dclk, dd);
  endspecify

  always @(posedge dclk) q <= dd;
endmodule

module test_31_extra_negative_condition_args;
  reg clk = 0, d = 1, en = 1, ts = 1, tc = 1;
  wire q;

  tnc_cell u(clk, d, en, ts, tc, q);

  initial begin
    #10 clk = 1;
    #2 $display("t=%0d clk=%b dclk=%b d=%b dd=%b en=%b ts=%b tc=%b",
                $time, clk, u.dclk, d, u.dd, en, ts, tc);
    #3 clk = 0;
    #5 clk = 1;
    #2 $display("t=%0d q=%b n=%b", $time, q, u.n);
    $finish;
  end
endmodule
