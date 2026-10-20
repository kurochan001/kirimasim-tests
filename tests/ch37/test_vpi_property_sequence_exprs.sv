/*
:name: test_vpi_property_sequence_exprs
:description: Property and sequence expressions appear as operations with the operation types and operand orders that the standard gives, a multiclocked sequence as clocked sequences, and a sequence instance with its arguments including defaults (IEEE 1800-2023 Section 37.52)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.52 37.54 37.56 37.51 37.53
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_sequence_exprs.c
:expected_stdout: @test_vpi_property_sequence_exprs.expected
*/
// IEEE 1800-2023 §37.54: in a sequence expression, a ##[1:3] b is an operation
// of type vpiCycleDelayOp with the operands left sequence, right sequence, left
// range and right range, and c[*2] one of type vpiConsecutiveRepeatOp with the
// sequence and the bound, the right bound left out when it equals the left.
// vpiArgument of a sequence instance returns its arguments in the order of the
// formals, with the default for one not given. §37.56: a multiclocked sequence
// expression iterates its clocked sequences, each with its clocking event.
// §37.52: the property spec of a declaration gives its clocking event and its
// property expression, here an operation of type vpiOverlapImplyOp whose second
// operand is a vpiNexttimeOp with one operand, and an s_eventually with a range
// is a strong vpiEventuallyOp with three operands. The declarations are found
// from the module (37.51, 37.53).

`timescale 1ns/1ns

module test_vpi_property_sequence_exprs;
  logic clk = 0, clk2 = 0, a = 0, b = 0, c = 0;

  sequence s_delay;
    a ##[1:3] b;
  endsequence

  sequence s_rep;
    c[*2];
  endsequence

  sequence s_multi;
    @(posedge clk) a ##1 @(posedge clk2) b;
  endsequence

  sequence s_arg(x, n = 2);
    x[*n];
  endsequence

  property p_imp;
    @(posedge clk) a |-> nexttime b;
  endproperty

  property p_ev;
    @(posedge clk) s_eventually [1:2] c;
  endproperty

  property p_inst;
    @(posedge clk) s_arg(a);
  endproperty

  initial #1 $vt_exprs;
endmodule
