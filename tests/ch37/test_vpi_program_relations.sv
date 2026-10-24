/*
:name: test_vpi_program_relations
:description: a program gives its default clocking block and its default disable condition, iterates its continuous assignments, clocking blocks and processes, each of which leads back to it through vpiInstance; a program array iterates its elements, and an element leads to its array through vpiInstanceArray (IEEE 1800-2023 Section 37.9)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.9 37.10 37.11 24.3 14.12 16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_program_relations.c
:expected_stdout: @test_vpi_program_relations.expected
*/
// IEEE 1800-2023 §37.9: a program has the one-to-one relations
// vpiDefaultClocking to its default clocking block (§14.12) and
// vpiDefaultDisableIff to the expression of its default disable iff
// (§16.15), and one-to-many relations to its continuous assignments
// (vpiContAssign), clocking blocks (vpiClockingBlock) and processes
// (vpiProcess), each of which leads back to it through vpiInstance (§37.10
// detail 3). An instance array of programs iterates its elements with
// vpi_iterate(vpiProgram), and an element leads to its array through
// vpiInstanceArray, which is NULL for a program that is not in an array
// (§37.11). p1 and p2 are instances of a program (§24.3) with two continuous
// assignments, the clocking blocks cb1 and cb2, the second one its default,
// a default disable iff on rst, an initial and a final procedure; pa is an
// array of two of them, and q is an instance of a program with an initial
// procedure only. The application prints each relation with what it gives
// and whether vpiInstance gives the expected program; lists are sorted. The
// output is printed from a cbStartOfSimulation callback, before the
// programs run. The VPI headers of Icarus Verilog 13.0 lack the constants
// used here, and in Verilator 5.052 vpiDefaultClocking of a program is NULL.

program test_vpi_program_relations_prog;
  logic clk = 1'b0, rst = 1'b0;
  wire w1, w2;

  assign w1 = clk;
  assign w2 = rst;

  clocking cb1 @(posedge clk);
  endclocking

  default clocking cb2 @(negedge clk);
  endclocking

  default disable iff (rst);

  initial clk = 1'b1;

  final rst = 1'b1;
endprogram

program test_vpi_program_relations_plain;
  logic v;

  initial v = 1'b0;
endprogram

module test_vpi_program_relations;
  test_vpi_program_relations_prog p1();
  test_vpi_program_relations_prog p2();
  test_vpi_program_relations_prog pa [1:0] ();
  test_vpi_program_relations_plain q();
endmodule
