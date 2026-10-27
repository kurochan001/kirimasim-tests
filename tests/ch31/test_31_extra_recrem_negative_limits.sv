/*
:name: test_31_extra_recrem_negative_limits
:description: A $recrem with a negative removal limit and a positive recovery limit whose sum is above the precision unit builds and runs, and its named delayed reference and delayed data are the delayed signals of the check (IEEE 1800-2023 Sections 31.3.6 and 31.9)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.6 31.9 31.9.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_31_extra_recrem_negative_limits.expected
*/
// IEEE 1800-2023 31.3.6: $recrem has the same negative-limit rule as
// $setuphold (31.9): when either limit is negative, the removal limit plus
// the recovery limit shall exceed one simulation unit of precision. Here the
// recovery limit is 7 ns and the removal limit is -2 ns with a precision of
// 1 ns, so -2 + 7 = 5 is above 1. The eighth and ninth arguments name drst
// and dclk as the delayed reference and delayed data. Icarus Verilog 13.0
// does not perform timing checks and replaces these delayed signals by
// copies of rst_n and clk, which is the behavior of 31.9.4 when timing checks
// are disabled. An asynchronous reset flip-flop on the copies is cleared when
// rst_n falls and sets its output at each rising edge of clk. The test shows
// the copies after the release of the reset, at a rising clock edge and when
// the reset falls again. A check that delayed drst or dclk would show the old
// value of the copy at the same time step and a different output.

`timescale 1ns/1ns

module trn_cell(input wire rst_n, input wire clk, output reg q = 0);
  wire drst, dclk;

  specify
    $recrem(posedge rst_n, posedge clk, 7, -2, , , , drst, dclk);
  endspecify

  always @(posedge dclk or negedge drst)
    if (!drst) q <= 0;
    else q <= 1;
endmodule

module test_31_extra_recrem_negative_limits;
  reg rst_n = 1, clk = 0;
  wire q;

  trn_cell u(rst_n, clk, q);

  task show;
    $display("t=%0d rst_n=%b drst=%b clk=%b dclk=%b q=%b",
             $time, rst_n, u.drst, clk, u.dclk, q);
  endtask

  initial begin
    #2 rst_n = 0;
    #3 rst_n = 1;
    #1 show;          // 6: reset released
    #4 clk = 1;
    #2 show;          // 12: dclk follows clk, q is set
    #3 clk = 0;
    #5 rst_n = 0;
    #2 show;          // 22: drst follows rst_n, q is cleared
    $finish;
  end
endmodule
