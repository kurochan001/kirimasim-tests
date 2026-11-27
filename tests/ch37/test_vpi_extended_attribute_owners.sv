/*
:name: test_vpi_extended_attribute_owners
:description: Attributes on primitive terminals, path terminals, module paths, timing checks, and UDP table entries
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.83 37.35 37.36 37.39 37.40 5.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_extended_attributes/client.c
:expected_stdout: @test_vpi_extended_attribute_owners.expected
:files: vpi_extended_attributes/client.h vpi_extended_attributes/seed.cpp vpi_extended_attributes/seeded.expected
*/
`timescale 1ns/1ns

primitive attr_owner_udp(y, a, b);
  output y;
  input a, b;
  table
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

module attr_owner_timing(input wire a, b, output wire y);
`ifdef ATTRIBUTE_ON_GATE_TERMINAL
  (* gate_owner = 17 *) and gate_with_terms(y, (* term_mark = 7 *) a, b);
`else
  (* gate_owner = 17 *) and gate_with_terms(y, a, b);
`endif

  specify
    (a => y) = 7;
    (b => y) = 11;
    $setup(a, posedge b, 2);
    $hold(posedge b, a, 3);
  endspecify
endmodule

module test_vpi_extended_attribute_owners;
  logic a = 1, b = 0;
  wire y, z;
  attr_owner_timing u(a, b, y);
  attr_owner_udp udp(z, a, b);

  initial begin
    #1 $vt_extended_attributes;
    $finish(0);
  end
endmodule
