/*
:name: test_dpi_declaration_scope_kinds
:description: DPI imports and exports are declared and used in a module, a program, an interface, a package, the compilation-unit scope and a generate block, and a context import of each of these scopes calls the export of the same scope (IEEE 1800-2023 Section 35.5.4, H.9.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.9.2 35.5.3 24.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_declaration_scope_kinds.c
:expected_stdout: @test_dpi_declaration_scope_kinds.expected
*/
// IEEE 1800-2023 H.9.2: DPI imports and exports can be declared in a module,
// a program, an interface, a package, the compilation-unit scope or a
// generate block. §35.5.4: an export can be called from C; §35.5.3: a context
// import can call exports, and one declared in the same scope as the export
// needs no svSetScope.
//
// Each scope declares a plain import c_<scope>_add, which adds its two
// arguments, a context import c_<scope>_call, which returns 1 plus what the
// export of the same scope returns, and that export, which multiplies its
// argument by a factor of its own: 2 for the compilation unit, 3 for the
// package, 4 for the module, 5 for the interface, 6 for the program and 7
// for the generate block. The calls run at different times, from inside each
// scope where it has procedures and from the module for the package and the
// compilation unit: the module at 0, the generate block at 1, the interface
// at 2 and the program at 3. The program's initial procedure is the only one
// in a program, so the simulation ends when it is done (24.3).

import "DPI-C" function int c_unit_add(input int a, input int b);
import "DPI-C" context function int c_unit_call(input int v);
export "DPI-C" function sv_unit_x2;

function int sv_unit_x2(input int v);
  return 2 * v;
endfunction

package dsk_pkg;
  import "DPI-C" function int c_pkg_add(input int a, input int b);
  import "DPI-C" context function int c_pkg_call(input int v);
  export "DPI-C" function sv_pkg_x3;

  function int sv_pkg_x3(input int v);
    return 3 * v;
  endfunction
endpackage

interface dsk_ifc;
  import "DPI-C" function int c_ifc_add(input int a, input int b);
  import "DPI-C" context function int c_ifc_call(input int v);
  export "DPI-C" function sv_ifc_x5;

  function int sv_ifc_x5(input int v);
    return 5 * v;
  endfunction

  initial #2 $display("interface: add %0d, call %0d", c_ifc_add(1, 1), c_ifc_call(2));
endinterface

program dsk_prg;
  import "DPI-C" function int c_prg_add(input int a, input int b);
  import "DPI-C" context function int c_prg_call(input int v);
  export "DPI-C" function sv_prg_x6;

  function int sv_prg_x6(input int v);
    return 6 * v;
  endfunction

  initial #3 $display("program: add %0d, call %0d", c_prg_add(1, 2), c_prg_call(3));
endprogram

module test_dpi_declaration_scope_kinds;
  import "DPI-C" function int c_mod_add(input int a, input int b);
  import "DPI-C" context function int c_mod_call(input int v);
  export "DPI-C" function sv_mod_x4;

  function int sv_mod_x4(input int v);
    return 4 * v;
  endfunction

  dsk_ifc i1();
  dsk_prg p1();

  if (1) begin : gb
    import "DPI-C" function int c_gen_add(input int a, input int b);
    import "DPI-C" context function int c_gen_call(input int v);
    export "DPI-C" function sv_gen_x7;

    function int sv_gen_x7(input int v);
      return 7 * v;
    endfunction

    initial #1 $display("generate block: add %0d, call %0d", c_gen_add(2, 2), c_gen_call(4));
  end

  initial begin
    $display("module: add %0d, call %0d", c_mod_add(3, 3), c_mod_call(5));
    $display("package: add %0d, call %0d", dsk_pkg::c_pkg_add(5, 6), dsk_pkg::c_pkg_call(7));
    $display("compilation unit: add %0d, call %0d", c_unit_add(2, 3), c_unit_call(4));
  end
endmodule
