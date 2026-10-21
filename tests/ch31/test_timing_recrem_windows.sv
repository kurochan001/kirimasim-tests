/*
:name: test_timing_recrem_windows
:description: $recrem with positive limits reports simultaneous events, a data event inside the recovery window after the reference event, and one inside the removal window before it, excluding the far end of each window (IEEE 1800-2023 Section 31.3.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.6 31.3.4 31.3.5 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_recrem_windows.expected
*/
// IEEE 1800-2023 §31.3.6: $recrem(posedge clr, posedge clk, 4, 3, n) has a
// recovery limit of 4 and a removal limit of 3. When the data event clk comes
// second, it is a violation when it is at or after clr and less than 4 later;
// when it comes first, a violation when clr follows within 3, the moment 3
// earlier not included; reference and data events at the same time are a
// violation. So the pairs at 10 (together), 50 and 53 (3 apart, recovery)
// and 90 and 92 (clk 2 before clr, removal) are violations, while 30 and 34
// (4 apart) and 70 and 73 (clk 3 before clr) are not. §31.6: each violation
// toggles the notifier, which the test prints when it changes.
// Icarus Verilog 13.0 and Verilator 5.052 skip timing checks, so the notifier
// never changes (docs/simulator-differences.md).

`timescale 1ns/1ns

module timing_recrem(input clr, input clk);
  reg n = 0;
  specify
    $recrem(posedge clr, posedge clk, 4, 3, n);
  endspecify
endmodule

module test_timing_recrem_windows;
  reg clr = 0, clk = 0;

  timing_recrem u(clr, clk);

  always @(u.n) $display("%0d: n=%b", $time, u.n);

  initial begin
    #10 clr = 1; clk = 1;  // 10: together
    #5 clr = 0; clk = 0;
    #15 clr = 1;           // 30
    #4 clk = 1;            // 34: 4 after clr, end of the window
    #4 clk = 0; clr = 0;
    #12 clr = 1;           // 50
    #3 clk = 1;            // 53: 3 after clr
    #4 clk = 0; clr = 0;
    #13 clk = 1;           // 70
    #3 clr = 1;            // 73: 3 after clk
    #4 clk = 0; clr = 0;
    #13 clk = 1;           // 90
    #2 clr = 1;            // 92: 2 after clk
    #4 clk = 0; clr = 0;
    #10 $finish;
  end
endmodule
