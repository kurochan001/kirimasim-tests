/*
:name: test_timing_vector_hold
:description: A $hold check on a vector data signal takes a change of any number of its bits at one time as one transition, so it reports one violation for each such change inside the window (IEEE 1800-2023 Section 31.8)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.8 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_vector_hold.expected
*/
// IEEE 1800-2023 §31.8: a timing check on a vector is one check, and a change
// of one or more bits of the vector is one transition of it. §31.3.2: $hold
// reports a violation at each data transition from the reference edge up to,
// not including, the limit after it, so unlike $setup it can report several
// per clock edge. After the edge at 10, three bits change at 11 and one bit
// at 13: two transitions, two violations, and the notifier toggles twice
// (31.6). The change of four bits at 15, exactly the limit of 5 after the
// edge, is outside the window. After the edge at 30, the data does not
// change.

`timescale 1ns/1ns

module test_timing_vector_hold_check (input clk, input [7:0] dat);
  reg notifier = 0;
  specify
    $hold(posedge clk, dat, 5, notifier);
  endspecify
endmodule

module test_timing_vector_hold;
  reg clk = 0;
  reg [7:0] dat = 8'b0000_0000;
  string log = "";

  test_timing_vector_hold_check u (clk, dat);

  always @(u.notifier) log = {log, $sformatf(" %0t:%b", $time, u.notifier)};

  initial begin
    #10 clk = 1;
    #1 dat = 8'b0000_0111;      // 11: three bits
    #2 dat = 8'b0000_0101;      // 13: one bit
    #2 dat = 8'b1111_0101;      // 15: four bits, at the end of the window
    #5 clk = 0;
    #10 clk = 1;                // 30
    #10 $display("notifier changes:%s", log);
  end
endmodule
