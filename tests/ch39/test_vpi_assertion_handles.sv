/*
:name: test_vpi_assertion_handles
:description: VPI finds concurrent assertions by iterating all of them, those of one instance, and by name, and gives each its type, names, instance, module, source line and whether its clock is inferred (IEEE 1800-2023 Section 39.3)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.3.1 39.3.2 37.49 37.50 16.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_handles.c
:expected_stdout: @test_vpi_assertion_handles.expected
*/
// IEEE 1800-2023 §39.3.1: vpi_iterate(vpiAssertion, NULL) gives every
// assertion in the design, vpi_iterate(vpiAssertion, instance) those of one
// instance, and vpi_handle_by_name finds a named assertion, by its full name or
// relative to a scope. §39.3.2, §37.49, §37.50: an assertion has its type
// (vpiAssert, vpiAssume, vpiCover, vpiRestrict), vpiName, vpiFullName, its
// instance (vpiInstance) with the module's vpiDefName, its source location
// (vpiFile, vpiStartLine) and vpiIsClockInferred, which is true for c_ack,
// clocked by the default clocking. §16.14: the unnamed assertion gets a name
// from the tool, so the application counts it without printing its name. The
// order of vpi_scan is not relied on: the named assertions are sorted. The
// clock never toggles, so no assertion is attempted.

`timescale 1ns/1ns

module ah_leaf(input logic clk, input logic req, input logic ack);
  default clocking cb @(posedge clk); endclocking
  c_ack: cover property (req ##1 ack);
endmodule

module test_vpi_assertion_handles;
  logic clk = 0, req = 0, ack = 0;

  ah_leaf u(.clk(clk), .req(req), .ack(ack));

  a_req: assert property (@(posedge clk) req |-> ##1 ack);
  m_ack: assume property (@(posedge clk) ack |-> !req);
  r_req: restrict property (@(posedge clk) !req);
  assert property (@(posedge clk) !(req && ack));

  initial $vt_assertions;
endmodule
