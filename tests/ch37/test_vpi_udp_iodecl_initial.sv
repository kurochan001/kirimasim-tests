/*
:name: test_vpi_udp_iodecl_initial
:description: each io declaration of a UDP definition leads back to that definition, and a sequential UDP definition gives its initial statement, an initial process whose statement is the assignment of the initial value, while a combinational one has none (IEEE 1800-2023 Section 37.36)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.36 37.63 37.64 29.3.2 29.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_udp_iodecl_initial.c
:expected_stdout: @test_vpi_udp_iodecl_initial.expected
*/
// IEEE 1800-2023 §37.36: a UDP definition iterates its io declarations
// (29.3.2), and the one-to-one relation from an io declaration to the UDP
// definition gives the definition it belongs to; the one-to-one relation to
// initial gives the initial statement of a sequential UDP (29.3.3), an object
// of type vpiInitial (37.63) whose vpiStmt is the assignment of the initial
// value (37.64), here 1 for set1 and 0 for set0. A combinational UDP has no
// initial statement, so the relation gives NULL. The definitions are reached
// from the instances with vpiUdpDefn; io declarations are printed by name,
// sorted.

primitive test_vpi_udp_iodecl_initial_set1 (q, s, r);
  output q;
  reg q;
  input s, r;
  initial q = 1'b1;
  table
    1 0 : ? : 1;
    0 1 : ? : 0;
    0 0 : ? : -;
  endtable
endprimitive

primitive test_vpi_udp_iodecl_initial_set0 (q, s, r, k);
  output q;
  reg q;
  input s, r, k;
  initial q = 1'b0;
  table
    1 0 ? : ? : 1;
    0 1 ? : ? : 0;
    0 0 ? : ? : -;
  endtable
endprimitive

primitive test_vpi_udp_iodecl_initial_xor2 (y, a, b);
  output y;
  input a, b;
  table
    0 0 : 0;
    0 1 : 1;
    1 0 : 1;
    1 1 : 0;
  endtable
endprimitive

module test_vpi_udp_iodecl_initial;
  logic s = 1'b0, r = 1'b0, k = 1'b0;
  wire q1, q0, y;

  test_vpi_udp_iodecl_initial_set1 u1 (q1, s, r);
  test_vpi_udp_iodecl_initial_set0 u0 (q0, s, r, k);
  test_vpi_udp_iodecl_initial_xor2 ux (y, s, r);

  initial #1 $vt_udps;
endmodule
