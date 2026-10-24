/*
:name: test_vpi_property_operator_kinds
:description: property operations have the operation types of their operators, with their operands in the order of the syntax except for nexttime, always and eventually; vpiOpStrong tells strong from weak forms, a sequence expression, a property instance and a plain expression can be property expressions, and a property spec gives its clocking event (IEEE 1800-2023 Section 37.52)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.52 37.51 16.12 16.12.3 16.12.4 16.12.6 16.12.7 16.12.8 16.12.9 16.12.10 16.12.11 16.12.12 16.12.13 16.12.14 16.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_operator_kinds.c
:expected_stdout: @test_vpi_property_operator_kinds.expected
*/
// IEEE 1800-2023 §37.52 (detail 2): within a property expression vpiOpType is
// one of the property operators, here vpiNotOp (16.12.3), vpiCompOrOp
// (16.12.4), vpiIfElseOp and vpiIfOp (16.12.6), vpiNonOverlapImplyOp
// (16.12.7), vpiImpliesOp and vpiIffOp (16.12.8), vpiOverlapFollowedByOp and
// vpiNonOverlapFollowedByOp (16.12.9), vpiNexttimeOp (16.12.10), vpiAlwaysOp
// (16.12.11), vpiUntilOp and vpiUntilWithOp (16.12.12), vpiEventuallyOp
// (16.12.13) and vpiAcceptOnOp, vpiRejectOnOp, vpiSyncAcceptOnOp and
// vpiSyncRejectOnOp (16.12.14). The operands come in the order of the syntax,
// told apart here by using different signals, except that nexttime gives the
// property and then the count, left out when it is 1, and always and
// eventually give the property, then the left and the right bound of the
// range. vpiOpStrong (detail 3) is TRUE for the strong form of nexttime,
// always, eventually, until and until_with, and for a sequence expression
// made strong with strong() (16.12.2), which is then the property expression
// itself, here a binary ## operation with its operands and range. A property
// instance (p_inner in p_inst) and an expression (the body of p_inner) are
// property expressions too, and the clocking event of a property spec is the
// operation posedge clk or negedge clk2. Each property is printed on one line,
// operations as their operator in parentheses.

module test_vpi_property_operator_kinds;
  logic clk = 1'b0, clk2 = 1'b0, a = 1'b0, b = 1'b0, c = 1'b0;

  property p_inner;
    a;
  endproperty

  property p_inst;
    not p_inner;
  endproperty

  property p_not;
    not b;
  endproperty

  property p_or;
    a or b;
  endproperty

  property p_ifelse;
    if (a) b else c;
  endproperty

  property p_if;
    if (c) a;
  endproperty

  property p_iff;
    a iff b;
  endproperty

  property p_implies;
    b implies c;
  endproperty

  property p_nimp;
    a |=> c;
  endproperty

  property p_ofb;
    b #-# a;
  endproperty

  property p_nofb;
    c #=# b;
  endproperty

  property p_acc;
    accept_on (c) a;
  endproperty

  property p_rej;
    reject_on (b) c;
  endproperty

  property p_sacc;
    sync_accept_on (a) b;
  endproperty

  property p_srej;
    sync_reject_on (c) a;
  endproperty

  property p_until;
    c until a;
  endproperty

  property p_suntil;
    a s_until c;
  endproperty

  property p_uw;
    a until_with b;
  endproperty

  property p_suw;
    b s_until_with c;
  endproperty

  property p_next;
    nexttime c;
  endproperty

  property p_snext3;
    s_nexttime [3] a;
  endproperty

  property p_alw;
    always b;
  endproperty

  property p_salw;
    s_always [1:2] c;
  endproperty

  property p_ev;
    eventually [1:2] a;
  endproperty

  property p_sev;
    s_eventually [2:3] b;
  endproperty

  property p_seqw;
    weak(a ##1 b);
  endproperty

  property p_seqs;
    strong(b ##2 c);
  endproperty

  property p_clk;
    @(posedge clk) a;
  endproperty

  property p_clk2;
    @(negedge clk2) b;
  endproperty

  initial #1 $vt_props;
endmodule
