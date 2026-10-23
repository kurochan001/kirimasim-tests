/*
:name: test_vpi_import_referenced_items
:description: vpi_iterate(vpiImport) of a module gives the package items that its import declarations actually bring in, the explicitly imported one and the wildcard-visible ones it references, and not the items of the package it never uses (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_import_referenced_items.c
:expected_stdout: @test_vpi_import_referenced_items.expected
*/
// IEEE 1800-2023 §37.12: vpiImport from a scope iterates the instance items
// imported into it by import declarations. Only the objects actually
// referenced through an import are returned, not every item that a wildcard
// import makes visible (detail 4, 26.3). The module imports imp_pkg with a
// wildcard and b explicitly, and uses a, b, P, the type two_t and the function
// f; the package also holds c, the event ev and the task t, which the module
// never uses. So the iteration gives P, a, b, f and two_t: a parameter, two
// variables, a function and a typespec. The application prints each item's
// name and kind, sorted by name, and the full names of the variables, which
// begin with the package name and :: (37.10 detail 5).

package imp_pkg;
  int a = 1, b = 2, c = 3;
  parameter int P = 4;
  typedef logic [1:0] two_t;
  event ev;

  function automatic int f();
    return 7;
  endfunction

  task automatic t();
  endtask
endpackage

module test_vpi_import_referenced_items;
  import imp_pkg::*;
  import imp_pkg::b;

  two_t tv;
  int sum;

  initial begin
    tv = 2'b01;
    sum = a + b + P + f();
    #1 $vt_imports;
  end
endmodule
