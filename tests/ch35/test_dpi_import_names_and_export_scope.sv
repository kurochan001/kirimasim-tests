/*
:name: test_dpi_import_names_and_export_scope
:description: two imported SystemVerilog names with one c_identifier call the same foreign function, an import with no arguments calls a foreign function of no arguments, two modules resolve the same linkage name to the same global symbol, and an exported function is called from foreign code through a context import (IEEE 1800-2023 Sections 35.2.1, 35.4, 35.5.1.3 and 35.7)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.1 35.4 35.5.1.3 35.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_names_and_export_scope.c
:expected_stdout: @test_dpi_import_names_and_export_scope.expected
*/
// IEEE 1800-2023 §35.2.1: one foreign subroutine may implement more than one
// SystemVerilog function, and an import may have zero or more formals.
// §35.4: every import resolves to a global symbol and every export defines
// one, so the two names first and second and the name child_same of another
// module all reach the one C function c_shared. §35.5.1.3: an import that
// calls an exported SystemVerilog function needs the context property.
// §35.7: an export declaration makes an SV function callable from foreign
// code; here the context import call_export calls the C function that calls
// the exported sv_times.
//
// c_shared multiplies its argument by 3, c_none returns 7, c_add adds, and
// call_export returns sv_times(a,b). The child module prints at 2 ns and the
// top module at 1 and 3 ns, so the order of the top-level processes is fixed.

module dpi_child;
  import "DPI-C" c_shared = function int child_same(input int a);

  initial #2 $display("child same foreign function=%0d", child_same(8));
endmodule

module test_dpi_import_names_and_export_scope;
  import "DPI-C" c_shared = function int first(input int a);
  import "DPI-C" c_shared = function int second(input int a);
  import "DPI-C" c_none = function int nothing();
  import "DPI-C" c_add = function int add(input int a, input int b);
  import "DPI-C" context function int call_export(input int a, input int b);
  export "DPI-C" function sv_times;

  function int sv_times(input int a, input int b);
    return a * b;
  endfunction

  dpi_child u();

  initial begin
    #1 begin
      $display("first=%0d second=%0d nothing=%0d", first(5), second(6), nothing());
      $display("add=%0d export=%0d", add(2, 3), call_export(4, 5));
    end
  end
endmodule
