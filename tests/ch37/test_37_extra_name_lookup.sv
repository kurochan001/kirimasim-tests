/*
:name: test_37_extra_name_lookup
:description: vpi_handle_by_name finds a local variable but cannot find an item imported into a scope or an object that exists within the compilation unit, although those objects exist and give their full names (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 37.12 38.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_37_extra_name_lookup.c
:expected_stdout: @test_37_extra_name_lookup.expected
*/
// IEEE 1800-2023 §37.10 detail 6: imported items and objects that exist
// within a compilation unit shall not be accessible via vpi_handle_by_name.
// §37.10 detail 5: vpiFullName of an object in a compilation unit begins with
// "$unit::" and that of an object in a package begins with the package name
// and "::". The application first shows that the objects exist by iterating
// the variables of the scopes that hold them (37.10 makes a package an
// instance and 37.12 gives the variables of a scope; this tool exposes the
// compilation-unit scope as a package) and printing the full names the
// standard fixes. It then asks vpi_handle_by_name for each of
// them: the local variable of the module is found, while the imported item and
// the compilation-unit object are not found under any name that could denote
// them.

package test_37_extra_name_lookup_pkg;
  int imported_item;
endpackage

int unit_item;

module test_37_extra_name_lookup;
  import test_37_extra_name_lookup_pkg::*;
  int local_var;

  initial begin
    local_var = 1;
    imported_item = 2;
    unit_item = 3;
    #1 $vt_lookup;
  end
endmodule
