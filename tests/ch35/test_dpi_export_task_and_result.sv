/*
:name: test_dpi_export_task_and_result
:description: exported functions and an exported task omit the c_identifier, so foreign code calls them by their SystemVerilog names; the export declarations come before the definitions; the imported contexts that call them are context imports; and the small result types of the exported functions cross the boundary (IEEE 1800-2023 Sections 35.5.5, 35.7, 35.8 and 35.5.1.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.5 35.7 35.8 35.5.1.3 35.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_task_and_result.c
:expected_stdout: @test_dpi_export_task_and_result.expected
*/
// IEEE 1800-2023 §35.7: an export declaration without a c_identifier gives
// the function the linkage name of the SystemVerilog function, the declaration
// may come before or after the definition, and each function has one export.
// §35.8: an exported task follows the same rules. §35.5.5: a function result
// crosses the boundary when its type is one of the supported small types, here
// int and shortint. §35.5.1.3: the import that calls the exports is declared
// context, which the call chain needs.
//
// The C function calls the task, which prints twice its argument, and then the
// two functions and prints their results: 105 and 6.

module test_dpi_export_task_and_result;
  export "DPI-C" task sv_task;
  export "DPI-C" function sv_alias;
  export "DPI-C" function sv_short;
  import "DPI-C" context function void call_exports(input int a);

  task sv_task(input int a);
    $display("task=%0d", a * 2);
  endtask

  function int sv_alias(input int a);
    return a + 100;
  endfunction

  function shortint sv_short(input shortint a);
    return a + 1;
  endfunction

  initial call_exports(5);
endmodule
