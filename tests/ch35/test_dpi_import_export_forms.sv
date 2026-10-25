/*
:name: test_dpi_import_export_forms
:description: DPI import declarations with the "DPI-C" string, the pure and context properties, a C identifier, a prototype without a port list and a task, and DPI export declarations of a function, of a function with a C identifier and of a task, with the calls that cross the boundary (IEEE 1800-2023 Sections 35.5.4, 35.7 and 35.8)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 35.7 35.8 A.2.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_export_forms.c
:expected_stdout: @test_dpi_import_export_forms.expected
*/
// IEEE 1800-2023 A.2.6: a DPI import is import, a DPI specification string,
// an optional function or task import property, an optional C identifier and
// a prototype, with the properties pure and context for a function and
// context for a task; a DPI export is export, the string, an optional C
// identifier, function or task and the identifier, which is the one of the
// subroutine defined in the same scope. The import and export prototypes are
// the ordinary function and task prototypes.
//   - di_add is a plain import with two named formals,
//   - di_pure is pure and returns twice its argument,
//   - di_ctx is context and calls the two exported functions of the module,
//     which needs the context property,
//   - di_task is a context task that calls the exported task sv_bump,
//   - di_link names the C function dlink with the C identifier form, so the
//     C function returns 107 for 7,
//   - di_flat is a function prototype with no port list and returns 42,
//   - sv_triple is exported under its own name, sv_square under the C name
//     slink and sv_bump as a task.
// Printed: add = 5, pure = 10, ctx = 18 + 36 = 54, link = 107, flat = 42,
// tri = 12, sq = 25 and bump = 4.
//
// Icarus Verilog 13.0 has no DPI. The 5.052 release of Verilator does not
// support the form here.

module test_dpi_import_export_forms;
  import "DPI-C" function int di_add(input int a, input int b);
  import "DPI-C" pure function int di_pure(input int a);
  import "DPI-C" context function int di_ctx(input int a);
  import "DPI-C" context task di_task(input int a);
  import "DPI-C" dlink = function int di_link(input int a);
  import "DPI-C" function int di_flat;

  export "DPI-C" function sv_triple;
  export "DPI-C" slink = function sv_square;
  export "DPI-C" task sv_bump;

  int bumped;

  function int sv_triple(input int v);
    return 3 * v;
  endfunction

  function int sv_square(input int v);
    return v * v;
  endfunction

  task sv_bump(input int v);
    bumped = bumped + v;
  endtask

  initial begin
    bumped = 0;
    di_task(4);
    #1 $display("add=%0d pure=%0d ctx=%0d link=%0d flat=%0d",
                di_add(2, 3), di_pure(5), di_ctx(6), di_link(7), di_flat());
    $display("tri=%0d sq=%0d bump=%0d",
             sv_triple(4), sv_square(5), bumped);
  end
endmodule
