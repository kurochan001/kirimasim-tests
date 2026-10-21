/*
:name: test_vpi_statement_kinds
:description: an atomic statement without a label gives a NULL vpiName, always_ff and always_latch processes give their always types, assignments with -=, |= and <<<= give the operator, an intra-assignment event control has no statement and a repeat control gives its count and event control, a priority casex gives its type and qualifier, a case matches gives tagged patterns with and without a nested pattern, and force, release, assign and deassign give a bit-select or a concatenation as their left-hand side (IEEE 1800-2023 Sections 37.60, 37.63, 37.64, 37.72 and 37.79)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.60 37.63 37.64 37.65 37.69 37.72 37.79 37.12 12.6 10.6 11.4.1 9.3.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_statement_kinds.c
:expected_stdout: @test_vpi_statement_kinds.expected
*/
// IEEE 1800-2023 §37.60: vpiName of an atomic statement is NULL when it has no
// label; no statement here has one, as a label would also make a named block
// around it (9.3.5). §37.63: vpiAlwaysType is vpiAlwaysFF for
// always_ff and vpiAlwaysLatch for always_latch, and a process gives its
// statement. §37.64: vpiOpType of an assignment with an assignment operator is
// the operator combined with it (§11.4.1): vpiSubOp for -=, vpiBitOrOp for |=
// and vpiArithLShiftOp for <<<=. An assignment leads to its intra-assignment
// timing control: an event control, whose statement is NULL (§37.65 detail
// 1), or a repeat control, which gives its count and its event control
// (§37.69). §37.72: a case gives vpiCaseType and vpiQualifier, here vpiCaseX
// and vpiPriorityQualifier; in a case matches (§12.6), the expressions of the
// items are patterns: tagged A .n is a tagged pattern with a nested pattern,
// tagged B one without. §37.79: force and release of the net bit w[1] have a
// bit-select as vpiLhs, assign and deassign of {p1, p2} a concatenation
// (§10.6), whose operands are printed sorted. The statements are in the task
// stmts, which is never called; the task gives them in an unnamed begin (37.12
// detail 5). The statements and the items of a case are printed sorted.

`timescale 1ns/1ns

module test_vpi_statement_kinds;
  typedef union tagged {
    int A;
    void B;
  } u_t;

  logic clk = 0, en = 0, d = 0, q, l, r1, r2, p1, p2;
  logic [3:0] x = 4'd9;
  int acc = 20;
  wire [1:0] w = 2'b00;
  u_t u;

  always_ff @(posedge clk) q <= d;
  always_latch if (en) l = d;

  task stmts;
    acc -= 3;
    acc |= 4;
    x <<<= 1;
    r1 = @(posedge clk) d;
    r2 = repeat (2) @(posedge clk) d;
    priority casex (x)
      4'b1??0: acc = 1;
      default: acc = 2;
    endcase
    case (u) matches
      tagged A .n: acc = n;
      tagged B: acc = 0;
    endcase
    force w[1] = 1'b1;
    release w[1];
    assign {p1, p2} = 2'b10;
    deassign {p1, p2};
  endtask

  initial #1 $vt_stmts;
endmodule
