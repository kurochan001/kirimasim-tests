/*
:name: test_module_items_nonport_kinds
:description: The items of a non-ANSI module can be port declarations and non-port items such as a generate region, a specify block, an attributed specparam declaration, a genvar declaration, a clocking declaration, default clocking and default disable iff, and each of them takes effect (IEEE 1800-2023 Section 23.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.4 23.2.2.1 27.3 30.4 6.20.5 14.3 14.11 14.12 16.15 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_items_nonport_kinds.expected
*/
// IEEE 1800-2023 A.1.4: a module item is a port declaration followed by a
// semicolon or a non-port module item; a non-port module item can be a
// generate region, a module_or_generate_item, a specify block or a
// specparam declaration with attribute instances; a
// module_or_generate_item_declaration can be a package_or_generate item
// declaration, a genvar declaration, a clocking declaration,
// "default clocking name;" or "default disable iff expression;".
// The non-ANSI module mk_dut has all of these:
//   - port declarations (23.2.2.1) give a, w and y their directions and w
//     and wneg 4 bits: wneg = ~4'h3 = c;
//   - the specparams tD = 3 and tE = tD + 2 (6.20.5): the path delay of the
//     specify block (30.4) is tD, so y follows the rise of a at 50 at 53
//     (y is 0 at 52 and 1 at 54), and tE is 5;
//   - genvar gi, used by the for loop of the generate region (27.3), which
//     makes g_l[0..2] with sq = gi * gi, so g_l[2].sq is 4;
//   - the clocking block cb samples d at each rise of clk (14.3): at 22, d
//     is 0 but cb.d still has the 1 sampled at 15;
//   - default clocking cb makes ##2 wait for two rises of clk (14.11,
//     14.12): from 0 to 15;
//   - default disable iff rst (16.15) applies to the assertion a_d, whose
//     clock is that of the default clocking. Rises of clk are at 5, 15, ...,
//     55; d is 0 from 20 to 40 and rst is 1 from 20 to 30, so the
//     evaluation at 25 is disabled (neither pass nor fail, 16.12) and the one
//     at 35 fails: 4 passes (5, 15, 45, 55) and 1 failure.
// Icarus Verilog 13.0 stops with a syntax error at default disable iff and
// does not support clocking blocks or concurrent assertions; the specify
// block alone gives the expected y there. The 5.052 release of Verilator
// ignores the path delay of the specify block and prints y=1 at 52; the
// other lines are as expected.

`timescale 1ns/1ns

module mk_dut (clk, rst, d, a, w, y, wneg);
  input clk;
  input rst;
  input d;
  input a;
  input [3:0] w;
  output y;
  output [3:0] wneg;

  (* sp_kind = "delay" *) specparam tD = 3, tE = tD + 2;
  genvar gi;
  clocking cb @(posedge clk);
    input d;
  endclocking
  default clocking cb;
  default disable iff (rst);
  int passes = 0, fails = 0;

  assign wneg = ~w;
  buf b1 (y, a);
  specify
    (a => y) = tD;
  endspecify

  generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : g_l
      int sq = gi * gi;
    end
  endgenerate

  a_d: assert property (d) passes++; else fails++;

  initial begin
    ##2;
    $display("##2 ended at %0t", $time);
  end
  initial #22 $display("at 22 d=%b cb.d=%b", d, cb.d);
  initial #52 $display("at 52 y=%b", y);
  initial #54 $display("at 54 y=%b tE=%0d", y, tE);
  initial #60 $display("passes=%0d fails=%0d sq=%0d wneg=%h", passes, fails, g_l[2].sq, wneg);
endmodule

module test_module_items_nonport_kinds;
  logic clk = 1'b0, rst = 1'b0, d = 1'b1, a = 1'b0;
  wire y;
  wire [3:0] wneg;

  mk_dut u (clk, rst, d, a, 4'h3, y, wneg);

  always #5 clk = ~clk;

  initial begin
    #20 d = 1'b0;
    rst = 1'b1;
    #10 rst = 1'b0;
    #10 d = 1'b1;
    #10 a = 1'b1;
    #20 $finish;
  end
endmodule
