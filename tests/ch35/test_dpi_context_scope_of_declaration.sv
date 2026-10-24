/*
:name: test_dpi_context_scope_of_declaration
:description: A context import called through a hierarchical name from another module runs in the scope of its declaration, in a module, interface or generate block instance, whose name is the full name of the import without its own name; it can call an export of that scope without svSetScope, and svGetScopeFromName finds generate block scopes (IEEE 1800-2023 Section 35.5.3, H.9.2, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.2 H.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_scope_of_declaration.c
:expected_stdout: @test_dpi_context_scope_of_declaration.expected
*/
// IEEE 1800-2023 §35.5.3, H.9.2: a context import runs in the context of the
// instantiated scope around its declaration, not in that of the place it is
// called from, which can be anywhere in the hierarchy; that context is the
// full name of the import minus the import's own name. An export of the same
// scope that the import calls gets that context too, without svSetScope, as
// if the import were a native function. H.9.3: svGetScope returns the scope,
// svGetNameFromScope its name, and svGetScopeFromName also finds generate
// block scopes.
//
// The top module calls the imports of u2, of the interface instance i1 and of
// the generate block gb[1] through hierarchical names; each returns the name
// of its scope. u1.c_whoami calls the export unit_id of its module with no
// svSetScope, so it gets u1's ID, 1; the top module has no unit_id. Then
// c_lookup_gen finds gb[0] and gb[1] by name and calls the export gen_id of
// each.
//
// In Verilator 5.052 an import called through a hierarchical name runs in the
// scope of the caller, and svGetScopeFromName finds no generate block scope
// (see the simulator differences document); Icarus Verilog 13.0 has no DPI.
// So :oracle: names no simulator.

module dcs_unit #(parameter int ID = 0) ();
  import "DPI-C" context function string c_where();
  import "DPI-C" context function int c_whoami();
  export "DPI-C" function unit_id;

  function int unit_id();
    return ID;
  endfunction
endmodule

interface dcs_ifc;
  import "DPI-C" context function string c_where_ifc();
endinterface

module test_dpi_context_scope_of_declaration;
  import "DPI-C" context function void c_lookup_gen();

  dcs_unit #(.ID(1)) u1();
  dcs_unit #(.ID(2)) u2();
  dcs_ifc i1();

  for (genvar g = 0; g < 2; g++) begin : gb
    import "DPI-C" context function string c_where_gen();
    export "DPI-C" function gen_id;

    function int gen_id();
      return 50 + g;
    endfunction
  end

  initial begin
    $display("u2.c_where from the top module: %s", u2.c_where());
    $display("u1.c_whoami from the top module: %0d", u1.c_whoami());
    $display("i1.c_where_ifc from the top module: %s", i1.c_where_ifc());
    $display("gb[1].c_where_gen from the top module: %s", gb[1].c_where_gen());
    c_lookup_gen();
  end
endmodule
