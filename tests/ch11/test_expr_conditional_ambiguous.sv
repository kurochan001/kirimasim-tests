/*
:name: test_expr_conditional_ambiguous
:description: an ambiguous conditional evaluates both branches, returns the equivalent branch, and combines unequal integral, aggregate array and other results as Table 11-20 and Table 7-1 say (IEEE 1800-2023 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_expr_conditional_ambiguous.expected
*/
// IEEE 1800-2023 §11.4.11: when the predicate is x or z both branches are
// evaluated and compared for logical equivalence; an equivalent pair returns
// either value. Unequal integral branches are combined bit by bit with
// Table 11-20 (equal bits keep their value, 0 with 1 or 1 with 0 gives x, and
// an x or z in either operand gives x), after extension to one width. Unequal
// same-length nonassociative aggregate arrays are combined element by element,
// keeping a matching element and using the Table 7-1 value of the element type
// for an element that differs; any other type takes the Table 7-1 value of the
// result type.
// The test prints the result of each case with %h or %b, so a simulator that
// picks one branch, or that combines unequal aggregates element by element
// bitwise instead of by element, prints a different line. Both releases
// simulated here return one branch or combine the unequal cases differently,
// so the expected output follows the clauses.

module test_expr_conditional_ambiguous;
  logic [7:0] a, b, r;
  logic [3:0] n4;
  logic sel;
  int arr_a [2];
  int arr_b [2];
  int arr_r [2];
  logic [3:0] larr_a [2];
  logic [3:0] larr_b [2];
  logic [3:0] larr_r [2];
  typedef struct packed { logic [3:0] f; } nib_t;
  nib_t nib;
  real rr;

  initial begin
    sel = 1'bx;
    a = 8'h0f;
    b = 8'h0f;
    r = sel ? a : b;
    $display("eq=%h", r);
    a = 8'h0f;
    b = 8'hf0;
    r = sel ? a : b;
    $display("neq=%h", r);
    a = 8'h00;
    b = 8'h00;
    r = sel ? a : b;
    $display("zero=%h", r);
    a = 8'hff;
    b = 8'hff;
    r = sel ? a : b;
    $display("ones=%h", r);
    sel = 1'bz;
    a = 8'h0f;
    b = 8'hf0;
    r = sel ? a : b;
    $display("zneq=%h", r);
    sel = 1'bx;
    n4 = 4'hf;
    b = 8'h0f;
    r = sel ? n4 : b;
    $display("wide=%h", r);
    nib = 4'hf;
    b = 8'h0f;
    r = sel ? nib : b;
    $display("packed=%h", r);
    nib = 4'hf;
    b = 8'hf0;
    r = sel ? nib : b;
    $display("packedneq=%h", r);
    arr_a[0] = 1;
    arr_a[1] = 2;
    arr_b[0] = 1;
    arr_b[1] = 3;
    arr_r = sel ? arr_a : arr_b;
    $display("arr=%0d,%0d", arr_r[0], arr_r[1]);
    larr_a[0] = 4'h1;
    larr_a[1] = 4'h2;
    larr_b[0] = 4'h1;
    larr_b[1] = 4'h3;
    larr_r = sel ? larr_a : larr_b;
    $display("larr=%b,%b", larr_r[0], larr_r[1]);
    rr = sel ? 1.5 : 2.5;
    $display("real=%0.1f", rr);
    $finish;
  end
endmodule
