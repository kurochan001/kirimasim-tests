/*
:name: test_vpi_property_instance_links
:description: An assertion's property gives its disable condition with vpiDisableCondition, an assertion clocked by a clocking block gives that block, and a multiclock sequence expression is a property expression (IEEE 1800-2023 Sections 37.49, 37.51, 37.52)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.49 37.51 37.52 16.12 16.13.1 14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_instance_links.c
:expected_stdout: @test_vpi_property_instance_links.expected
*/
// IEEE 1800-2023 §37.51: the property of an assertion gives the expression of
// its disable iff condition with vpiDisableCondition (37.51 diagram). §37.52:
// a multiclock sequence expression is a member of the property expression
// group, so a property whose body is @(posedge clk1) a ##1 @(posedge clk2) b
// has a multiclock sequence expression as its property expression (37.52
// diagram). §37.49: an assertion gives the clocking block of its clocking
// event with vpiClockingBlock (diagram). The clocks never tick, so no
// assertion is evaluated.

module test_vpi_property_instance_links;
  logic clk1 = 1'b0, clk2 = 1'b0, a = 1'b0, b = 1'b0, rst = 1'b0;

  property p_multi;
    @(posedge clk1) a ##1 @(posedge clk2) b;
  endproperty

  clocking cb @(posedge clk1);
  endclocking

  a2: assert property (disable iff (rst) a |-> b);
  a3: assert property (p_multi);
  a4: assert property (@(cb) a);

  initial #1 $vt_props;
endmodule
