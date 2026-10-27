/*
:name: test_dpi_context_scope
:description: A context import runs in the scope of the instance whose import declaration it uses: svGetNameFromScope names it, user data is kept per scope, and svSetScope selects which instance an export runs in (IEEE 1800-2023 Section H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 H.9.3 35.5.3 H.9.1 H.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_scope.c
:expected_stdout: @test_dpi_context_scope.expected
*/
// IEEE 1800-2023 §35.5.3, H.9.3: a context import is given the scope of the
// instance that holds the import declaration; svGetScope returns it and
// svGetNameFromScope gives its full hierarchical name. svPutUserData and
// svGetUserData keep data per scope and key, so the two instances of
// dpi_scope_unit recall their own values. svGetScopeFromName and svSetScope
// select the scope in which a later call of an export runs, so the export
// unit_id answers for the named instance.

`timescale 1ns/1ns

module dpi_scope_unit #(parameter int ID = 0) ();
  import "DPI-C" context function string dpi_where();
  import "DPI-C" context function void dpi_remember(input int v);
  import "DPI-C" context function int dpi_recall();
  export "DPI-C" function unit_id;

  function int unit_id();
    return ID;
  endfunction

  initial begin
    #(ID) $display("unit %0d: %s", ID, dpi_where());
    dpi_remember(ID * 100);
    #10 $display("unit %0d: recalled %0d", ID, dpi_recall());
  end
endmodule

module test_dpi_context_scope;
  import "DPI-C" context function int dpi_id_of(input string scope);

  dpi_scope_unit #(.ID(1)) u1();
  dpi_scope_unit #(.ID(2)) u2();

  initial begin
    #5 $display("unit_id in u2: %0d", dpi_id_of("test_dpi_context_scope.u2"));
    $display("unit_id in u1: %0d", dpi_id_of("test_dpi_context_scope.u1"));
  end
endmodule
