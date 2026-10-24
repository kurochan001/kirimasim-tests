/*
:name: test_program_and_checker_instantiate_checkers
:description: A program instantiates two checkers, one of which instantiates another checker twice; the assertion of each of the four leaf checker instances checks its own input and reports its own failure (IEEE 1800-2023 Section 3.11)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.11 3.6 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_and_checker_instantiate_checkers.expected
*/
// IEEE 1800-2023 §3.11: programs and checkers can instantiate other
// checkers. §17.3: a checker can be instantiated wherever a concurrent
// assertion can appear, which includes the items of a program and of a
// checker. §3.6: a checker, between checker and endchecker, holds
// assertions.
// The leaf checker cc_leaf_chk asserts that its input a is 0 at each rising
// clock edge; its failure action prints the time and its id input. The
// checker cc_mid_chk instantiates it for each bit of its 2-bit input (ids
// 0 and 1), and the program cc_prog instantiates cc_mid_chk on a and
// cc_leaf_chk directly on b (id 9). The clock rises at 5, 15, 25 and 35,
// and the inputs change only between edges: a is 01 at 5, 10 at 15 and 00
// afterwards, and b is 1 only at 25. So bit 0 fails at 5, bit 1 at 15 and
// the direct instance at 25, one failure at a time. The program prints at
// time 40, and its end ends the simulation (§24.3).
// Neither Icarus Verilog 13.0 nor the 5.052 release of Verilator accepts
// this design: Icarus does not support checkers, and the other release does
// not accept a checker instance inside a checker or a program (syntax
// error), so the expected output follows the clauses alone.

`timescale 1ns/1ns

checker cc_leaf_chk(input logic clk, input logic a, input int id);
  a_low: assert property (@(posedge clk) !a)
    else $display("t=%0t leaf %0d: a is 1", $time, id);
endchecker : cc_leaf_chk

checker cc_mid_chk(input logic clk, input logic [1:0] a);
  cc_leaf_chk u_bit0(clk, a[0], 0);
  cc_leaf_chk u_bit1(clk, a[1], 1);
endchecker : cc_mid_chk

program cc_prog(input logic clk, input logic [1:0] a, input logic b);
  cc_mid_chk u_mid(clk, a);
  cc_leaf_chk u_direct(clk, b, 9);

  initial #40 $display("t=%0t program: done", $time);
endprogram

module test_program_and_checker_instantiate_checkers;
  logic clk = 0;
  logic [1:0] a = 2'b01;
  logic b = 0;

  always #5 clk = ~clk;

  cc_prog u_prog(clk, a, b);

  initial begin
    #10 a = 2'b10;
    #10 a = 2'b00;
    b = 1;
    #10 b = 0;
  end
endmodule
