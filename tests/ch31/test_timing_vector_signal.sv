/*
:name: test_timing_vector_signal
:description: A timing check on a vector treats a change of any number of its bits as one transition, so a $setup reports one violation per clock edge however many bits changed (IEEE 1800-2023 Section 31.8)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.8 31.3.1 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_vector_signal.expected
*/
// IEEE 1800-2023 §31.8: with an 8-bit data signal, $setup (31.3.1) is a single
// timing check, and a change of one or more bits is one transition of the
// vector. At 100 six bits change and the clock rises at 105, inside the
// window of 10: one violation, so the notifier toggles once (31.6). At 112
// one bit changes before the edge at 115: another violation. Changes at 121
// and 123 before the edge at 125 are two transitions, but $setup reports a
// violation at its reference event, once.

`timescale 1ns/1ns

module dff8 (input clk, input [7:0] dat);
  reg notifier = 0;
  specify
    $setup(dat, posedge clk, 10, notifier);
  endspecify
endmodule

module test_timing_vector_signal;
  reg clk = 0;
  reg [7:0] dat = 8'b00101110;
  string log = "";

  dff8 u (clk, dat);

  always @(u.notifier) log = {log, $sformatf(" %0d:%b", $time, u.notifier)};

  initial begin
    #100 dat = 8'b01010011;
    #5 clk = 1;          // 105
    #5 clk = 0;
    #2 dat[0] = 0;       // 112
    #3 clk = 1;          // 115
    #5 clk = 0;
    #1 dat[1] = 0;       // 121
    #2 dat[4] = 0;       // 123
    #2 clk = 1;          // 125
    #10 $display("notifier changes:%s", log);
  end
endmodule
