/*
:name: test_vpi_net_local_active_connectivity
:description: vpiLocalDriver and vpiLocalLoad of the nets of a module give the continuous assignments and primitive terminals in it and its own ports (input and inout ports drive, output and inout ports load); vpiDriver and vpiLoad give a force or procedural assign statement only while it is active, and vpiDriver gives a port driven by a variable (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 37.46 10.6.1 10.6.2 28.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_local_active_connectivity.c
:expected_stdout: @test_vpi_net_local_active_connectivity.expected
*/
// IEEE 1800-2023 §37.16: vpiLocalDriver and vpiLocalLoad give only the
// drivers and loads inside the instance that contains the net, together with
// the ports connected to the net: input and inout ports are drivers, output
// and inout ports are loads (detail 17), and these sets are the same in every
// implementation (detail 22). In u, a is driven by its port and read by the
// assignment to n and the control terminal of g1 (28.6); n is driven by its
// assignment and read by the assignment to y and the data terminal of g1; y is
// driven by its assignment and loaded by its port; z is driven by its port and
// the output terminal of g1 and loaded by its port. vpiLoad gives only active
// force and assign statements, vpiDriver only active forces (details 14, 15,
// 10.6.1, 10.6.2): the force on ftgt and the procedural assign to rv, which
// read fsrc, appear while they are in effect and not after release and
// deassign. vpiDriver also gives a port driven by something other than a net
// (detail 16): the output port o of vs, which is a variable, drives tq. Since
// a tool may return the bits of an assignment or a port, those count as their
// parent (vpiParent); each list is sorted.

`timescale 1ns/1ns

module nlac_mod (input wire a, output wire y, inout wire z);
  wire n;

  assign n = a;
  assign y = n;
  bufif1 g1 (z, n, a);
endmodule

module nlac_vsrc (output logic o);
  assign o = 1'b1;
endmodule

module test_vpi_net_local_active_connectivity;
  wire ta, ty, tz, tq, ftgt;
  wire fsrc = 1'b1;
  logic rv;

  nlac_mod u (.a(ta), .y(ty), .z(tz));
  nlac_vsrc vs (.o(tq));

  assign ftgt = 1'b0;

  initial begin
    force ftgt = fsrc;
    assign rv = fsrc;
    #1 $vt_local;
    $vt_active("while in effect");
    release ftgt;
    deassign rv;
    #1 $vt_active("after release and deassign");
  end
endmodule
