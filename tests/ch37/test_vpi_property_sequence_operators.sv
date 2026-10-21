/*
:name: test_vpi_property_sequence_operators
:description: property operations give the operation types, operands and strengths the standard fixes for nexttime, always and until, a case property groups its conditions per item, a property spec gives its disable condition and clocked properties their clocks; sequence operations give the operands of ##, goto and nonconsecutive repetition and the types of throughout, within, first_match and intersect; a multiclocked sequence gives the clocks of its clocked sequences; a let declaration gives its name and formals with a default, and a let expression its declaration, value and arguments (IEEE 1800-2023 Sections 37.52, 37.54, 37.56 and 37.57)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.52 37.54 37.56 37.57 37.51 37.53 16.12 16.9 16.13.1 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_sequence_operators.c
:expected_stdout: @test_vpi_property_sequence_operators.expected
*/
// IEEE 1800-2023 §37.52 (details 2 and 3): the operands of a property operation
// follow the BNF, except that nexttime gives the property and then the
// constant, only when that is not 1, and always gives the property, then the
// left and right range; vpiOpStrong is TRUE for s_nexttime, s_always and
// s_until and FALSE for their weak forms (§16.12). A case property gives its
// condition and its items; an item groups all conditions that lead to its
// property, and the default item has none (details 4 and 5). A property spec
// gives the condition of disable iff, and a clocked property its clock and
// its property. §37.54 (detail 3): the operands of a sequence operation
// follow the BNF, except that ##2 a gives the sequence and the left range
// only, as the right range equals it, and a repetition gives the sequence,
// then the left bound and, if different, the right bound (§16.9). throughout,
// within, first_match and intersect have their own operation types (detail
// 2). §37.56: a sequence with three clocks (§16.13.1) can only be a multiclock
// sequence expression (37.53), as a clocked sequence holds a sequence
// expression, which has one clock; its clocked sequences give the three
// clocks, each printed once, sorted (how many clocked sequences there are is
// not fixed). §37.57: the module gives its let declarations (37.12); a let
// declaration has its name and its formals as seq formal
// decls, the default of q being its vpiExpr (37.53 detail 3); the let
// expression in the continuous assignment leads to the declaration, has the
// value of the let (§11.12) and gives its two arguments in the order of the
// formals (detail 1). The properties and sequences have no clock of their
// own, so that their bodies are property and sequence expressions.

`timescale 1ns/1ns

module test_vpi_property_sequence_operators;
  logic clk = 0, clk2 = 0, a = 0, b = 0, c = 0, rst = 0;
  logic [1:0] sel = 2'd0;
  int x = 3, y;

  property p_next;
    nexttime a;
  endproperty

  property p_next2;
    nexttime [2] a;
  endproperty

  property p_snext;
    s_nexttime a;
  endproperty

  property p_always;
    always [1:3] a;
  endproperty

  property p_salways;
    s_always [1:3] a;
  endproperty

  property p_until;
    a until b;
  endproperty

  property p_suntil;
    a s_until b;
  endproperty

  property p_case;
    case (sel)
      2'd0, 2'd1: a;
      2'd2: b;
      default: c;
    endcase
  endproperty

  property p_dis;
    disable iff (rst) a |-> b;
  endproperty

  property p_clocked;
    (@(posedge clk) nexttime a) and (@(posedge clk2) nexttime b);
  endproperty

  sequence s_udelay;
    ##2 a;
  endsequence

  sequence s_goto;
    b [->1:3];
  endsequence

  sequence s_nonconsec;
    c [=2];
  endsequence

  sequence s_throughout;
    a throughout (b ##1 c);
  endsequence

  sequence s_within;
    (a ##1 b) within (c ##[1:3] a);
  endsequence

  sequence s_first;
    first_match(a ##[1:2] b);
  endsequence

  sequence s_intersect;
    (a ##1 b) intersect (c ##1 a);
  endsequence

  sequence s_three_clocks;
    @(posedge clk) a ##1 @(posedge clk2) b ##1 @(negedge clk) c;
  endsequence

  let mix(p, q = 4) = p + q;

  assign y = mix(x, 2);

  initial #1 $vt_operators;
endmodule
