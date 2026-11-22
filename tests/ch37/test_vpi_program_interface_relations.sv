/*
:name: test_vpi_program_interface_relations
:description: vpiInstance of a scalar interface, an interface array and its elements connected to program ports returns the module that instantiates them (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 25.5 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_program_interface_relations.c
:expected_stdout: @test_vpi_program_interface_relations.expected
*/
// IEEE 1800-2023 37.10 detail 3: vpiInstance identifies the instance that
// instantiated the object. The module instantiates b and ba and passes them
// to programs through interface ports (25.5). Look up the actual interfaces
// in the module and compare their vpiInstance handles with the module. The
// program diagram in 37.9 does not say that a port connection instantiates
// another interface. This test makes no query from the program ports.
// Run at time 1, before the program initial procedures end (24.3).

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

  initial #1 $vt_program;
endmodule
