/*
:name: test_dpi_export_function
:description: A context imported function can call an exported SystemVerilog function under its C name, and exporting does not change the function for SystemVerilog callers (IEEE 1800-2023 Section 35.7)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.7 35.5.3 35.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_function.c
:expected_stdout: @test_dpi_export_function.expected
*/
// IEEE 1800-2023 §35.7: an export declaration lets C code in a DPI call chain
// call a SystemVerilog function, here under the C name sv_square (35.4); it
// does not change how the function behaves when SystemVerilog calls it.
// §35.5.3: only a context import may call an export, and an export called from
// it runs in the scope of the import declaration. The function counts its calls
// in a module variable, so both kinds of call are visible.

module test_dpi_export_function;
  import "DPI-C" context function int dpi_sum_of_squares(input int n);
  export "DPI-C" sv_square = function square;

  int calls = 0;

  function int square(input int x);
    calls++;
    return x * x;
  endfunction

  initial begin
    int s;
    s = dpi_sum_of_squares(4);
    $display("sum of squares 1..4 = %0d", s);
    $display("calls from C: %0d", calls);
    s = square(7);
    $display("square(7) = %0d, calls: %0d", s, calls);
  end
endmodule
