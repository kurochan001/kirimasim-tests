/*
:name: test_dpi_one_function_two_imports
:description: One C function can implement several imported SystemVerilog functions with their own names and default argument values, in a package, a module and a generate block, and imported subroutines are called like native ones, with defaults and binding by name (IEEE 1800-2023 Section 35.2.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.1 13.6 35.5.4 35.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_one_function_two_imports.c
:expected_stdout: @test_dpi_one_function_two_imports.expected
*/
// IEEE 1800-2023 §35.2.1: import declarations may appear wherever subroutine
// definitions may, and the same foreign subroutine can implement several
// SystemVerilog subroutines, for example to give them different default
// argument values; an imported task is used as a statement. §13.6, §35.6: an
// imported subroutine is called like a native one, so arguments with defaults
// can be left out and named arguments can be bound by name. §35.5.4: the
// declarations of c_offset in the package, the module and the generate block
// give it three SystemVerilog names and defaults 1, 10 and 100.

package test_dpi_one_function_two_imports_pkg;
  import "DPI-C" function int c_offset(input int a, input int b = 1);
endpackage

module test_dpi_one_function_two_imports;
  import test_dpi_one_function_two_imports_pkg::*;
  import "DPI-C" c_offset = function int plus_ten(input int a, input int b = 10);
  import "DPI-C" task c_keep(input int v);
  import "DPI-C" function int c_kept();

  if (1) begin : g
    import "DPI-C" c_offset = function int plus_hundred(input int a, input int b = 100);

    initial #1 $display("generate block: %0d", plus_hundred(1));
  end

  initial begin
    $display("package: %0d %0d", c_offset(1, 2), c_offset(5));
    $display("module: %0d %0d", plus_ten(5), plus_ten(.b(1), .a(2)));
    c_keep(7);
    $display("task kept %0d", c_kept());
  end
endmodule
