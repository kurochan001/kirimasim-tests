/*
:name: test_dpi_import_result_types_all_small
:description: An imported function returns each of the small result types that a DPI function prototype allows: void, byte, shortint, int, longint, real, shortreal, chandle, string, a scalar bit and a scalar logic (IEEE 1800-2023 Section 35.5.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.5 35.5.6 H.7.4 A.2.6 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_result_types_all_small.c
:expected_stdout: @test_dpi_import_result_types_all_small.expected
*/
// IEEE 1800-2023 §35.5.5 and footnote 26 of A.10 (on dpi_function_proto,
// A.2.6): the result type of an imported function is restricted to small
// values: void, byte, shortint, int, longint, real, shortreal, chandle,
// string, and scalar bit and logic. Table H.1 (H.7.4) gives the C type of
// each. Here one function returns each of these types, and each result is
// printed with a value that only the full width or the right type gives:
// a negative byte and shortint, an int and a longint past 16 and 32 bits,
// fractions for real and shortreal, a chandle that C dereferences, a string
// that C returns, and a bit and a logic that are 1 for odd arguments.
// dpi_r_set (void) stores its argument, which dpi_r_get returns.
// Icarus Verilog 13.0 has no DPI. The 5.052 release of Verilator gives
// every line but the shortreal result, which it prints as 0.00 (the C
// function returns a float, H.7.4).

module test_dpi_import_result_types_all_small;
  import "DPI-C" function void dpi_r_set(input int v);
  import "DPI-C" function int dpi_r_get();
  import "DPI-C" function byte dpi_r_byte(input int v);
  import "DPI-C" function shortint dpi_r_short(input int v);
  import "DPI-C" function int dpi_r_int(input int v);
  import "DPI-C" function longint dpi_r_long(input int v);
  import "DPI-C" function real dpi_r_real(input int v);
  import "DPI-C" function shortreal dpi_r_sreal(input int v);
  import "DPI-C" function chandle dpi_r_handle(input int v);
  import "DPI-C" function int dpi_r_deref(input chandle h);
  import "DPI-C" function string dpi_r_str(input int which);
  import "DPI-C" function bit dpi_r_bit(input int v);
  import "DPI-C" function logic dpi_r_logic(input int v);

  initial begin
    chandle h;
    dpi_r_set(42);
    $display("void: get=%0d", dpi_r_get());
    $display("byte: %0d", dpi_r_byte(3));
    $display("shortint: %0d", dpi_r_short(3));
    $display("int: %0d", dpi_r_int(3));
    $display("longint: %0d", dpi_r_long(3));
    $display("real: %0.3f shortreal: %0.2f", dpi_r_real(3), dpi_r_sreal(3));
    h = dpi_r_handle(77);
    $display("chandle: null=%0d deref=%0d", h == null, dpi_r_deref(h));
    $display("string: %s %s", dpi_r_str(0), dpi_r_str(1));
    $display("bit: %b %b logic: %b %b", dpi_r_bit(3), dpi_r_bit(4), dpi_r_logic(5),
             dpi_r_logic(6));
  end
endmodule
