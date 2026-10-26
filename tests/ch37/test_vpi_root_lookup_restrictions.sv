/*
:name: test_vpi_root_lookup_restrictions
:description: The NULL design root gives the top-level instances, a module and a package, with vpiInstance, and vpi_handle_by_name does not find an imported item or an object in the compilation unit while it finds a local object (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_root_lookup_restrictions.c
:expected_stdout: @test_vpi_root_lookup_restrictions.expected
*/
// IEEE 1800-2023 §37.10: the NULL design root relates to the top-level
// instances with the instance access type, traversed with vpi_iterate
// (37.10 diagram). Detail 6: vpi_handle_by_name shall not find imported items
// or objects that exist within a compilation unit. The package item pv is
// imported into the module and referenced there (26.3), and cu is declared
// outside every design element, so its full name begins with "$unit::"
// (detail 5); neither is found by name, while the module's own variable lvar
// is. The top-level module and the package are both instance objects, so the
// NULL root iteration gives both (37.10 diagram).

package rlr_pkg;
  int pv;
endpackage

int cu;

module rlr_child;
endmodule

module test_vpi_root_lookup_restrictions;
  import rlr_pkg::*;
  int lvar;
  rlr_child u ();

  initial begin
    cu = 7;
    pv = 8;
    lvar = 9;
    #1 $vt_lookup;
  end
endmodule
