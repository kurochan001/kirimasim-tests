/*
:name: test_checker_declaration_body_forms
:description: A checker declaration accepts an optional port list and closing label and a body of declarations, procedures, assertion items, continuous assignments and generate items (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.5 17.6 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_declaration_body_forms.expected
*/
// IEEE 1800-2023 §17.2, Syntax 17-1: checker/endchecker encloses an optional
// port list and an optional closing label, and the body may hold let,
// sequence, property and function declarations, a covergroup declaration and
// instance, clocking declarations, a default clocking, a default disable iff,
// genvar and data declarations, initial, always_comb, always_latch,
// always_ff and final procedures, assertion items, continuous assignments and
// checker generate items. The outer checker has a port list and no closing
// label; the nested checker has no port list and a closing label; both forms
// are instantiated. The body contains one of each item kind, and the design
// prints the values that the continuous, combinational, latch and sequential
// items drive. §17.5 and §17.6 constrain the procedures and the covergroup
// instance; §11.12 gives the let declarations. Icarus Verilog 13.0 has no
// checkers and Verilator 5.052 rejects several of these items, so the
// expected output follows the clauses alone.

`timescale 1ns/1ns

checker forms (input logic a, input logic b, input logic clk,
               output logic y, output int n);
  let inv = !a;
  sequence s_one;
    a ##1 b;
  endsequence
  property p_one;
    a |=> b;
  endproperty
  function automatic logic f (logic x);
    return ~x;
  endfunction
  covergroup cg @(posedge clk);
    cp_a: coverpoint a;
  endgroup : cg
  cg ci = new();
  clocking cb @(posedge clk);
    default input #1step;
  endclocking
  default clocking cb;
  default disable iff (!a);
  genvar gi;
  logic r;
  logic l;
  assign y = a;
  always_comb r = f(a);
  always_latch if (a) l = b;
  always_ff @(posedge clk) n <= n + 1;
  initial begin
    @(posedge clk);
    assert (a);
    assert #0 (b);
  end
  final $display("forms final y=%b", y);
  $info("checker forms elaborated");
  a1: assert property (p_one);
  a2: assert #0 (a);
  a3: cover property (@(posedge clk) a ##1 b);
  generate
    for (gi = 0; gi < 1; gi++) begin : gl
      logic gq;
      assign gq = a;
    end
    if (1) begin : gc
      logic gq;
      assign gq = b;
    end
  endgenerate
  checker nested (input logic c, output logic d);
    assign d = c;
  endchecker : nested
  logic nd;
  nested u_nested (.c(a), .d(nd));
endchecker

module test_checker_declaration_body_forms;
  logic clk = 1'b0;
  logic a = 1'b1;
  logic b = 1'b1;
  logic y;
  int n;

  forms u_forms (.a(a), .b(b), .clk(clk), .y(y), .n(n));

  always #5 clk = ~clk;   // rising edges at 5, 15 and 25

  initial begin
    #32 $display("forms a=%b y=%b n=%0d", a, y, n);
    $finish;
  end
endmodule
