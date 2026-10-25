/*
:name: test_svdpi_h_scope_selection
:description: svGetScope names the instance whose import declaration the running context import uses, svGetNameFromScope gives a scope's full hierarchical name, svGetScopeFromName finds module instance scopes by name and gives NULL for an unknown name, and svSetScope returns the previous scope and makes the selected one the scope of the export calls that follow (IEEE 1800-2023 Section 35.3.2, I.3, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_scope_selection.c
:expected_stdout: @test_svdpi_h_scope_selection.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.9.3: svGetScope gives the active instance scope of the running
// imported function, which is the scope of its declaration unless svSetScope
// has changed it; svGetNameFromScope gives the fully qualified name of a
// scope handle; svGetScopeFromName gives the scope of the module, interface,
// program or generate instance with the name it is given and NULL for a name
// it does not know; svSetScope makes a scope the active one and returns the
// scope that was active before, and an export called from an import without a
// call of svSetScope runs in the scope of that surrounding import.
//
// The two instances u7 and u9 of dpi_scope_unit each call c_here from their
// own initial block, u7 at time 1 and u9 at time 2, so svGetScope there has
// to name that instance and not the other. The top module calls c_lookups at
// time 5: it prints the name of its own scope, looks the two instances up by
// name and an unknown name, which has to give NULL, and then selects u9 and
// u7 in turn, printing what svSetScope returned and what the export unit_tag
// answers in the selected scope, and finally selects the top module again.

module dpi_scope_unit #(parameter int TAG = 0, parameter int DELAY = 0) ();
  import "DPI-C" context function void c_here(input string who);
  export "DPI-C" function unit_tag;

  function int unit_tag();
    return TAG;
  endfunction

  initial #(DELAY) c_here("in the unit");
endmodule

module test_svdpi_h_scope_selection;
  import "DPI-C" context function void c_lookups();

  dpi_scope_unit #(.TAG(7), .DELAY(1)) u7();
  dpi_scope_unit #(.TAG(9), .DELAY(2)) u9();

  initial #5 c_lookups();
endmodule
