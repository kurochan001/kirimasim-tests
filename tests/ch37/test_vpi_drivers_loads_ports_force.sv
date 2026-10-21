/*
:name: test_vpi_drivers_loads_ports_force
:description: Net and variable drivers and loads include ports, force statements and procedural assign statements; a complex expression on an input port makes the port a load whose high connection is that expression; a packed struct variable gets the drivers and loads of its part-selects, bit-selects and members (IEEE 1800-2023 Sections 37.46 and 37.21)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.46 37.21 37.16 37.14 23.3.3.7 10.6.1 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_drivers_loads_ports_force.c
:expected_stdout: @test_vpi_drivers_loads_ports_force.expected
*/
// IEEE 1800-2023 §37.46: the drivers and loads of a net include ports and
// force statements, and the loads also procedural assign statements. The
// force (§10.6.2) drives n; the input port of k2 is a load of n because the
// complex expression !n on an input port is a load (detail 1), and vpiHighConn
// of that port (37.14) gives the expression, an operation with vpiOpType
// vpiNotOp. n is joined to no port by a net, so no net collapsing (23.3.3.7)
// can change its drivers and loads (37.16 detail 22). m, read by the force,
// and w, read by the procedural assign statement (§10.6.1), have them as
// loads. §37.21: a variable is driven by a port (v), a force (f) or an assign
// statement (q); a force (g) or an assign statement (h) that reads it is a
// load. For a structure variable the drivers and loads
// include those of its part-selects, bit-selects and members (detail 1): ps is
// driven through ps[3:0] and ps.hi and read whole and through ps[7]. Whether a
// tool returns a continuous assignment or its bits is not fixed, so bits count
// as their assignment (vpiParent, 37.47), as port bits do as their port; kinds
// are sorted.

`timescale 1ns/1ns

module test_vpi_drivers_loads_ports_force_sink (input wire i, output wire o);
  assign o = i;
endmodule

module test_vpi_drivers_loads_ports_force_vsrc (output logic o);
  assign o = 1'b1;
endmodule

module test_vpi_drivers_loads_ports_force;
  typedef struct packed {
    logic [3:0] hi, lo;
  } pk_t;

  wire n, w, a2, z1;
  wire [7:0] z8;
  wire m = 1'b0;
  logic v, f, q;
  logic g = 1'b1, h = 1'b1;
  logic [3:0] x4 = 4'h3, y4 = 4'h5;
  pk_t ps;

  assign w = 1'b1;
  assign ps[3:0] = x4;
  assign ps.hi = y4;
  assign z1 = ps[7];
  assign z8 = ps;

  test_vpi_drivers_loads_ports_force_sink k2 (.i(!n), .o(a2));
  test_vpi_drivers_loads_ports_force_vsrc vs (.o(v));

  initial begin
    force n = m;
    force f = g;
    assign q = w & h;
    #1 $vt_dl;
    release n;
    release f;
    deassign q;
  end
endmodule
