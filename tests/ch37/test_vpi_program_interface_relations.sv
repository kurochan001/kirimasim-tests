/*
:name: test_vpi_program_interface_relations
:description: A program iterates the interface instances and interface arrays connected to its ports, and each interface instance and interface array element gives the program back with vpiInstance (IEEE 1800-2023 Section 37.9)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.9 25.5 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_program_interface_relations.c
:expected_stdout: @test_vpi_program_interface_relations.expected
*/
// IEEE 1800-2023 §37.9: a program has a one-to-many relation to the
// interface instances it is connected to (37.9 diagram, untagged interface
// access type) and a one-to-many relation to its interface arrays (untagged
// interface array access type); each interface instance and each element of
// an interface array has a one-to-one relation back to the program with
// vpiInstance. The program one takes a scalar interface port and the program
// two a port that is an array of two interfaces, so the scalar and the array
// relations are observed apart from each other. Interface instances are
// printed sorted by name, elements by index.

`timescale 1ns/1ns

interface pri_bus;
  logic v;
endinterface

program pri_one(pri_bus b);
  initial #2 b.v = 1'b1;
endprogram

program pri_two(pri_bus ba[0:1]);
  initial #3 begin
    ba[0].v = 1'b0;
    ba[1].v = 1'b1;
  end
endprogram

module test_vpi_program_interface_relations;
  pri_bus b();
  pri_bus ba[2]();
  pri_one one(b);
  pri_two two(ba);

  initial #4 $vt_program;
endmodule
