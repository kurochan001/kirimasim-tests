/*
:name: test_vpi_assertion_callback_targets
:description: Every assertion callback reason can be placed on a concurrent and on an immediate assertion, and the start, success and failure callbacks also on a property instance and on a sequence instance, which VPI gives as objects of the types vpiPropertyInst and vpiSequenceInst (IEEE 1800-2023 Sections 39.4.2 and 39.3.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 39.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_callback_targets.c
:expected_stdout: @test_vpi_assertion_callback_targets.expected
*/
// IEEE 1800-2023 §39.4.2: each assertion callback reason can be placed with
// vpi_register_assertion_cb on any concurrent or immediate assertion, and
// cbAssertionStart, cbAssertionSuccess and cbAssertionFailure also on a
// sequence instance or a property instance; a placed callback gives a handle.
// §39.3.2: a sequence instance and a property instance are among the kinds of
// assertion objects, with their own types (37.49). §37.50: the vpiProperty
// relation of a concurrent assertion leads to its property instance or
// property specification, and §37.52 a property specification leads to its
// property expression.
// a_p asserts the declared property p_ab, so its property is a property
// instance; c_s covers the declared sequence s_ab, which is the property
// expression of its property specification, a sequence instance. ia is an
// immediate assert, which the application finds by iterating all assertions
// (39.3.1). At 1, $vt_place tries all 19 assertion callback reasons on ca and
// on ia and the three reasons on the two instances, and prints how many were
// placed and the type of each instance. The callbacks do nothing.
// No simulator here runs the application: the expected output is derived from
// §39.4.2, §39.3.2, §37.50 and §37.52.

`timescale 1ns/1ns

module test_vpi_assertion_callback_targets;
  logic clk = 0, a = 0, b = 0;

  always #5 clk = ~clk;

  sequence s_ab;
    a ##1 b;
  endsequence

  property p_ab;
    @(posedge clk) a |-> b;
  endproperty

  ca: assert property (@(posedge clk) a |-> b) else ;
  a_p: assert property (p_ab) else ;
  c_s: cover property (@(posedge clk) s_ab);

  always @(a) begin : check
    ia: assert (a == a) else ;
  end

  initial begin
    #1 $vt_place;   // 1
    #9 b = 1;       // 10
    a = 1;
    #20 $finish;    // 30
  end
endmodule
