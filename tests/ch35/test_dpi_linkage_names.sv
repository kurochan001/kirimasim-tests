/*
:name: test_dpi_linkage_names
:description: Import declarations can give a C linkage name of their own, share one C function under two SystemVerilog names with different default arguments, and name a C function that is a SystemVerilog keyword (IEEE 1800-2023 Section 35.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.4 35.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_linkage_names.c
:expected_stdout: @test_dpi_linkage_names.expected
*/
// IEEE 1800-2023 §35.4: imported subroutines have a global C linkage name, by
// default the SystemVerilog name, or the c_identifier given before "=". A
// linkage name that is a SystemVerilog keyword is written as an escaped
// identifier, whose backslash and trailing space are not part of the C name.
// §35.5.4: the same C function may be imported under several SystemVerilog
// names, as long as the type signature is the same; argument names and default
// values may differ.

module test_dpi_linkage_names;
  import "DPI-C" dpi_scale = function int scale_by(input int x, input int k);
  import "DPI-C" dpi_scale = function int scale_by_ten(input int x, input int k = 10);
  import "DPI-C" \begin = function int plus_hundred(input int x);

  initial begin
    $display("scale_by(3, 4) = %0d", scale_by(3, 4));
    $display("scale_by_ten(3) = %0d", scale_by_ten(3));
    $display("scale_by_ten(3, 2) = %0d", scale_by_ten(3, 2));
    $display("plus_hundred(5) = %0d", plus_hundred(5));
  end
endmodule
