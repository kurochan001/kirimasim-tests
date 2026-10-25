/*
:name: test_program_and_checker_generate_items
:description: A generate construct inside a program declares only items that a program declaration allows outside a generate construct, such as an initial procedure, and one inside a checker declares only checker items, such as a concurrent assertion; the generated procedures give values and the generated assertion reports each of its passes (IEEE 1800-2023 Sections 24.3 and 17.2, footnotes 5 and 6 of A.10)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 17.2 A.9.3 A.2.9 A.2.10 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_and_checker_generate_items.expected
*/
// IEEE 1800-2023 footnote 5 of A.10: a program generate item cannot include
// an item that would be illegal in a program declaration outside a generate
// item; footnote 6 says the same for a checker generate item and a checker
// declaration. §24.3: a program item can be a variable declaration and an
// initial procedure, so the loop generate construct of the program pg holds
// an initial procedure with a variable of its own. §17.2: a checker item can
// be a concurrent assertion, so the loop generate construct of the checker ck
// holds one.
//
// The two generated program procedures print 1 at time 1 and 2 at time 2,
// each from its own pv. The generated assertion in c1 holds a at each posedge
// of clk, where a is 1, so it passes at times 5 and 15 and its pass action
// prints them.
//
// Icarus Verilog 13.0 has no checkers; Verilator 5.052 produces this output.

`timescale 1ns/1ns

checker ck (input logic clk, a);
  for (genvar i = 0; i < 1; i++) begin : cg
    assert property (@(posedge clk) a) $display("chk ok %0d", $time);
  end
endchecker

program prog;
  for (genvar i = 0; i < 2; i++) begin : pg
    initial begin
      int pv;
      pv = i + 1;
      #(i+1) $display("prog %0d", pv);
    end
  end
endprogram

module test_program_and_checker_generate_items;
  logic clk = 0, a = 1;

  always #5 clk = ~clk;

  ck c1 (clk, a);

  initial begin
    #20 $finish;
  end
endmodule
