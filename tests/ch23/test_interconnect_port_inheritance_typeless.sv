/*
:name: test_interconnect_port_inheritance_typeless
:description: An interconnect port has no data type, as the first port of an ANSI list or as a later port that gives only its kind, and a later port that omits direction, kind and type after an interconnect port is an interconnect port too, so all of them can carry a real user-defined nettype (IEEE 1800-2023 Section 23.2.2.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.3 6.6.8 6.6.7 23.3.3.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_port_inheritance_typeless.expected
*/
// IEEE 1800-2023 §23.2.2.3: when a port of an ANSI list omits its data type
// it defaults to logic, except for an interconnect port, which has no data
// type; this holds for the first port and for a later port that gives only
// its port kind. A later port that omits direction, port kind and data type
// after an interconnect port is also an interconnect port. An interconnect
// net or port is typeless (§6.6.8) and takes the type of what it connects
// (§23.3.3.7.1), here the user-defined nettype rnet of data type real
// (§6.6.7), which a logic port could not carry.
//   m1(interconnect p, q): p is the first port, an inout interconnect port
//      without data type; q inherits all three and is an interconnect port;
//   m2(input wire logic w, interconnect r): r inherits the direction input
//      and, being an interconnect port, gets no data type.
// Sources drive 2.5, 4.0 and 1.25 onto rnet nets through these ports, and
// readers with rnet inputs inside m1 and m2 receive them. If q or r were
// logic ports, the real values could not pass. Neither Icarus Verilog 13.0
// nor Verilator 5.052 supports interconnect nets and user-defined nettypes,
// so this expected output follows the standard alone.

package interconnect_port_inheritance_pkg;
  nettype real rnet;
endpackage

module interconnect_port_inheritance_src
  import interconnect_port_inheritance_pkg::*;
  #(parameter real V = 0.0) (output rnet o);
  assign o = V;
endmodule

module interconnect_port_inheritance_dst
  import interconnect_port_inheritance_pkg::*;
  (input rnet i);
endmodule

module interconnect_port_inheritance_m1(interconnect p, q);
  interconnect_port_inheritance_dst d1(p);
  interconnect_port_inheritance_dst d2(q);
endmodule

module interconnect_port_inheritance_m2(input wire logic w, interconnect r);
  interconnect_port_inheritance_dst d3(r);
endmodule

module test_interconnect_port_inheritance_typeless;
  interconnect np, nq, nr;
  wire nw = 1'b0;

  interconnect_port_inheritance_src #(2.5) s1(np);
  interconnect_port_inheritance_src #(4.0) s2(nq);
  interconnect_port_inheritance_src #(1.25) s3(nr);
  interconnect_port_inheritance_m1 m1(np, nq);
  interconnect_port_inheritance_m2 m2(nw, nr);

  initial begin
    #1;
    $display("m1.p (first port): %f", m1.d1.i);
    $display("m1.q (inherits interconnect): %f", m1.d2.i);
    $display("m2.r (interconnect, no data type): %f", m2.d3.i);
  end
endmodule
