/*
:name: test_dpi_import_unit_interface_program
:description: Import declarations in the compilation-unit scope, an interface and a program define subroutines there that are called like native ones, with no arguments, as void functions, through the interface instance, and as an imported task with an output argument (IEEE 1800-2023 Section 35.2.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.1 35.5.4 35.6 25.7 24.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_unit_interface_program.c
:expected_stdout: @test_dpi_import_unit_interface_program.expected
*/
// IEEE 1800-2023 §35.2.1: an import declaration can stand wherever a
// subroutine definition can and defines a subroutine of that scope; imported
// subroutines take zero or more input, output and inout arguments, an
// imported function may be void, and an imported task is called as a
// statement. Calls of imports look like calls of native subroutines (35.6).
// c_next_ticket, without arguments, is declared in the compilation-unit
// scope; c_store, a void function, and c_load are declared in an interface
// and called through its instance, as interface subroutines are (25.7); the
// program (24.3) calls its imported task c_sum_into, which returns its result
// in an output argument. The program prints at 2 and the module at 0 and 1.

import "DPI-C" function int c_next_ticket();

interface test_dpi_import_unit_interface_program_if;
  import "DPI-C" function void c_store(input int slot, input int value);
  import "DPI-C" function int c_load(input int slot);
endinterface

program test_dpi_import_unit_interface_program_prog;
  import "DPI-C" task c_sum_into(output int total, input int a, input int b);

  int total;

  initial begin
    #2 c_sum_into(total, 20, 22);
    $display("program: the imported task put %0d in its output", total);
  end
endprogram

module test_dpi_import_unit_interface_program;
  test_dpi_import_unit_interface_program_if bus();
  test_dpi_import_unit_interface_program_prog prog();

  int first, second;

  initial begin
    first = c_next_ticket();
    second = c_next_ticket();
    $display("compilation unit: tickets %0d and %0d", first, second);
    bus.c_store(3, 33);
    #1 $display("interface: slot 3 holds %0d", bus.c_load(3));
  end
endmodule
