/*
:name: test_vpi_unbounded_const_ranges
:description: The $ upper bound of a cycle delay range and of consecutive, goto and nonconsecutive repetition ranges in sequences and a property is a constant operand whose vpiConstType is vpiUnboundedConst, while numeric bounds are not (IEEE 1800-2023 Section 37.59)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.59 37.54 37.52 16.7 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_unbounded_const_ranges.c
:expected_stdout: @test_vpi_unbounded_const_ranges.expected
*/
// IEEE 1800-2023 §37.59 detail 4: the $ written as a bound of an assertion
// range is a constant whose vpiConstType is vpiUnboundedConst. §37.54 details
// 2 and 3: in a sequence expression, ## with a range is an operation of type
// vpiUnaryCycleDelayOp (operands: the sequence, the left and the right bound)
// or vpiCycleDelayOp (operands: the left and the right sequence, then the two
// bounds), and [*], [->] and [=] are vpiConsecutiveRepeatOp, vpiGotoRepeatOp
// and vpiRepeatOp (operands: the sequence, then the two bounds); the right
// bound is given only when it differs from the left one. §37.52: the property
// spec of a property declaration leads to its property expression, here a
// vpiOverlapImplyOp whose operands are the antecedent and the consequent.
// §16.7 and §16.9.2: $ as the upper bound of a delay or repetition range
// stands for a finite but unbounded maximum.
//
// Each sequence declaration has one range whose upper bound is $, except
// s_bounded, whose upper bound is 4, and the property p_imp has one in its
// consequent. From a start-of-simulation callback the application prints,
// for each declaration, the kind of operation and its operands in order: a
// signal by its name, a constant whose vpiConstType is vpiUnboundedConst as $,
// and any other constant by its value.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiOperation, vpiOperand and the operator
// and constant types used here, and Verilator 5.052 rejects the design, as it
// does not accept $ as the upper bound of the goto and nonconsecutive
// repetitions, which the grammar of §16.9.2 allows.

module test_vpi_unbounded_const_ranges;
  logic clk = 0, a = 0, b = 0;

  sequence s_unary;
    ##[1:$] b;
  endsequence

  sequence s_delay;
    a ##[2:$] b;
  endsequence

  sequence s_bounded;
    a ##[2:4] b;
  endsequence

  sequence s_consec;
    b [*1:$];
  endsequence

  sequence s_goto;
    b [->2:$];
  endsequence

  sequence s_nonconsec;
    b [=0:$];
  endsequence

  property p_imp;
    @(posedge clk) a |-> ##[3:$] b;
  endproperty
endmodule
