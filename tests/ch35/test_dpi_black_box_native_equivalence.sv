/*
:name: test_dpi_black_box_native_equivalence
:description: A function implemented in C and a native SystemVerilog function with the same declaration are called the same way and give the same results, through the C linkage layer of the DPI (IEEE 1800-2023 Section 35.2, 35.3, 35.3.1, 35.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2 35.3 35.3.1 35.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_black_box_native_equivalence.c
:expected_stdout: @test_dpi_black_box_native_equivalence.expected
*/
// IEEE 1800-2023 §35.2: the DPI is a black box, so the implementation of a
// function is transparent and its calls do not change. §35.3: the
// SystemVerilog layer is the same for every foreign layer, and an
// implementation shall support C protocols and linkage; the foreign side here
// is a C file with C linkage. §35.3.1: the argument passing of the foreign
// language is transparent to SystemVerilog. §35.5: an imported function is
// used with the same call syntax as a native one. c_poly and sv_poly both
// compute 3*x+1, and the C side keeps a value between calls, as a native
// function with a static variable would.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 produces this output.

module test_dpi_black_box_native_equivalence;
  import "DPI-C" function int c_poly(input int x);
  import "DPI-C" function void c_put(input int x);
  import "DPI-C" function int c_get();

  function int sv_poly(input int x);
    return 3 * x + 1;
  endfunction

  initial begin
    for (int x = -2; x <= 2; x++)
      $display("x=%0d c=%0d sv=%0d same=%0d", x, c_poly(x), sv_poly(x),
               c_poly(x) == sv_poly(x));
    c_put(42);
    $display("stored=%0d", c_get());
  end
endmodule
