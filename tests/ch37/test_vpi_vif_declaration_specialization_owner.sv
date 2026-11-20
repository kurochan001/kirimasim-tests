/*
:name: test_vpi_vif_declaration_specialization_owner
:description: Virtual interface declarations from two class specializations lead back to their own class typespec, distinguished by identity and parameter value
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.32 37.33
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_vif_declaration_specialization_owner.c
:expected_stdout: @test_vpi_vif_declaration_specialization_owner.expected
*/
// IEEE 1800-2023 37.32 B003-B007: the common single-arrow return from
// members of a class specialization goes to that class typespec. Detail 11
// includes virtual interface declarations in the corresponding iteration.
// By 37.33 detail 5 and 37.32 detail 1, the type of each class variable below
// is its resolved specialization even while that variable is null. The C
// application queries declaration metadata, not a live object's member value.
// Specialization names are tool-dependent (37.32 detail 4), so only source
// identifiers, parameter values, and object identity comparisons are printed.

interface test_vpi_vif_declaration_specialization_owner_bus;
  logic sig;
endinterface

module test_vpi_vif_declaration_specialization_owner;
  class holder #(int ID = 1);
    virtual test_vpi_vif_declaration_specialization_owner_bus vif;
  endclass
  holder #(3) owner3;
  holder #(8) owner8;
  initial #1 $vt_vif_owner;
endmodule
