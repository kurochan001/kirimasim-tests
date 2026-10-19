/*
:name: test_vpi_cont_assign_drivers
:description: a module gives its continuous assignments, including a net declaration assignment, with their left-hand net, delay, strengths and value; a net gives the continuous assignments and primitive terminals that drive it and those that read it (IEEE 1800-2023 Sections 37.47, 37.46)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.47 37.46 38.10 38.15 10.3.1 10.3.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_cont_assign_drivers.c
:expected_stdout: @test_vpi_cont_assign_drivers.expected
*/
// IEEE 1800-2023 §37.47: vpi_iterate(vpiContAssign, module) gives the
// continuous assignments of a module; each has vpiLhs, vpiRhs and, if it has
// one, vpiDelay, whose value vpi_get_delays returns (§38.10); vpiNetDeclAssign
// is true for an assignment in a net declaration (§10.3.1), vpiStrength0 and
// vpiStrength1 give its drive strengths (§10.3.4), and vpi_get_value its
// value (§38.15). §37.46: vpiDriver and vpiLoad iterate over what drives and
// what reads a net, such as continuous assignments and primitive terminals.
// The application prints one line per assignment, sorted, then the drivers
// and loads of some nets, with their types sorted.

`timescale 1ns/1ns

module test_vpi_cont_assign_drivers;
  logic [3:0] a = 4'd2;
  logic b = 1, c = 0;
  wire [3:0] w;
  wire (weak0, strong1) n = b;
  wire m, t, k, kn;

  assign #3 w = a + 1;
  assign m = b;
  assign m = c;
  assign k = n;
  and g(t, a[0], b);
  not g2(kn, n);

  initial #10 $vt_assigns;
endmodule
