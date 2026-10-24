/*
:name: test_vpi_sequence_decl_operands
:description: the formals of a sequence declaration give their typespec and direction, vpiNoDirection unless they are local variable arguments of direction input, output or inout; a sequence declaration gives its variables and full name; sequence operations, distributions and plain expressions are sequence expressions, and/or give vpiCompAndOp and vpiCompOrOp, the operands of cycle delays and repetitions come in the order the standard gives, and an expression with match items gives its assignment and subroutine call (IEEE 1800-2023 Sections 37.53 and 37.54)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.53 37.54 16.8 16.8.2 16.9.2 16.9.5 16.9.7 16.10 16.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_sequence_decl_operands.c
:expected_stdout: @test_vpi_sequence_decl_operands.expected
*/
// IEEE 1800-2023 §37.53: vpiSeqFormalDecl gives the formals of s_formals;
// vpiTypespec is NULL for the untyped x, a logic typespec for w and an int
// typespec for the local variable arguments (detail 2); vpiDirection is
// vpiNoDirection for x and w, which are not local variable arguments, and the
// declared direction input, output or inout for i, o and io (detail 4,
// 16.8.2). vpiVariables of s_vars gives its local variables cnt and flag
// (16.10); vpiFullName of a sequence decl is its hierarchical name, through
// the generate block g for s_gen. §37.54: operations, distributions and
// expressions are sequence expressions, the vpiExpr of a sequence decl here.
// Within a sequence expression and gives vpiCompAndOp and or vpiCompOrOp
// (detail 2, 16.9.5, 16.9.7). The operands follow the syntax except that a
// unary ## gives the sequence, then the left and, if different, the right
// bound of its range; a binary ## the left and the right sequence, then the
// bounds; a repetition (16.9.2) the repeated sequence, then its left bound and,
// if different, its right bound (detail 3). In s_match the expression a has
// the match items (16.10, 16.11) of its parenthesized sequence: the
// assignment to cnt2 and the call of the void function mark (vpiMatchItem).
// Operands are printed as names, values, or operations in parentheses.

module test_vpi_sequence_decl_operands;
  logic a = 1'b0, b = 1'b0, c = 1'b0;

  function void mark();
  endfunction

  sequence s_formals(x, logic [3:0] w = 4'd3, local input int i = 1, local output int o,
                     local inout int io);
    (x, o = i, io = io + i) ##1 x;
  endsequence

  sequence s_vars;
    int cnt;
    bit flag;
    (a, cnt = 2) ##1 b;
  endsequence

  if (1) begin : g
    sequence s_gen;
      a ##1 b;
    endsequence
  end

  sequence s_and;
    a and b;
  endsequence

  sequence s_or;
    b or c;
  endsequence

  sequence s_udel;
    ##[1:3] a;
  endsequence

  sequence s_udel2;
    ##2 b;
  endsequence

  sequence s_bdel;
    a ##[2:4] c;
  endsequence

  sequence s_bdel1;
    c ##1 b;
  endsequence

  sequence s_rep;
    a[*1:3];
  endsequence

  sequence s_rep2;
    b[*2];
  endsequence

  sequence s_goto;
    c[->2:4];
  endsequence

  sequence s_nc;
    a[=3];
  endsequence

  sequence s_dist;
    (a dist {1 := 1, 0 := 2}) ##1 b;
  endsequence

  sequence s_expr;
    a && b;
  endsequence

  sequence s_one;
    c;
  endsequence

  sequence s_match;
    int cnt2;
    (a, cnt2 = 1, mark()) ##1 b;
  endsequence

  initial #1 $vt_seqs;
endmodule
