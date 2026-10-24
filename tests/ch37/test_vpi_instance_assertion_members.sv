/*
:name: test_vpi_instance_assertion_members
:description: a property instance and a sequence instance belong to the assertion group, so they have the location properties of an assertion, lead to their module instance and take assertion callbacks, which come at the start, the success and the failure of their evaluations; a sequence instance can also be an operand of a sequence operation (IEEE 1800-2023 Sections 37.49 and 37.54)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.49 37.54 37.50 39.4.2 16.14.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_assertion_members.c
:expected_stdout: @test_vpi_instance_assertion_members.expected
*/
// IEEE 1800-2023 §37.49: sequence inst and property inst are members of the
// assertion group, whose relations and properties apply to them: vpiInstance
// gives the module instance and vpiFile and vpiStartLine the place in the
// source, here the line of the assertion that holds the instance. The
// instances are the property expression of the property spec of a_pi (the
// property p_a) and of c_si (the sequence s_ab), reached with vpiProperty
// (37.50). Assertion callbacks can be placed on them (39.4.2): for an instance
// the start is the start of its evaluation, at each clock tick 5, 15, 25 and
// 35; p_a succeeds where a is 1 (5, 25, 35) and fails at 15; s_ab = a ##1 b
// matches at 15 and 35 for the attempts of 5 and 25, fails at 15 for the
// attempt of 15, and the attempt of 35 has not ended at 40. §37.54: a
// sequence inst is a sequence expression, so it can be an operand, here the
// first operand of the ## of s_use, leading to its declaration s_ab. Callbacks
// are counted, since their order within a time step is not fixed.

`timescale 1ns/1ns

module test_vpi_instance_assertion_members;
  logic clk = 1'b0, a = 1'b1, b = 1'b1;
  int fails = 0, hits = 0;

  always #5 clk = ~clk;

  sequence s_ab;
    a ##1 b;
  endsequence

  sequence s_use;
    s_ab ##1 a;
  endsequence

  property p_a;
    a;
  endproperty

  a_pi: assert property (@(posedge clk) p_a) else fails = fails + 1;
  c_si: cover sequence (@(posedge clk) s_ab) hits = hits + 1;

  initial begin
    $vt_watch;
    #10 a = 1'b0;
    #10 a = 1'b1;
    b = 1'b0;
    #10 b = 1'b1;
    #10 $vt_report;
    $display("fail actions %0d, cover actions %0d", fails, hits);
    $finish;
  end
endmodule
