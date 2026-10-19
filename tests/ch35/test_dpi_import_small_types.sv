/*
:name: test_dpi_import_small_types
:description: Imported functions take and return the small DPI types by value: byte, shortint, int, longint, real, bit, string and chandle (IEEE 1800-2023 Section 35.5.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.5 35.5.6 H.7.4 H.8.7 H.8.9 H.8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_small_types.c
:expected_stdout: @test_dpi_import_small_types.expected
*/
// IEEE 1800-2023 §35.5.5: an imported function may return void, byte, shortint,
// int, longint, real, shortreal, chandle, string, or a scalar bit or logic.
// Table H.1 (H.7.4) gives the C type of each, and H.8.7 says these small input
// values are passed by value. H.8.10: a string reaches C as a null-terminated
// const char*, and a string that C returns is copied by SystemVerilog. A
// chandle carries a C pointer that SystemVerilog only stores and passes back.

module test_dpi_import_small_types;
  import "DPI-C" function byte dpi_neg_byte(input byte b);
  import "DPI-C" function shortint dpi_twice_shortint(input shortint s);
  import "DPI-C" function int dpi_add_int(input int a, input int b);
  import "DPI-C" function longint dpi_mul_longint(input longint a, input longint b);
  import "DPI-C" function real dpi_half_real(input real r);
  import "DPI-C" function bit dpi_not_bit(input bit b);
  import "DPI-C" function int dpi_strlen(input string s);
  import "DPI-C" function string dpi_word(input int which);
  import "DPI-C" function chandle dpi_new_counter(input int start);
  import "DPI-C" function int dpi_next(input chandle c);

  initial begin
    chandle c;
    int n1, n2;
    $display("byte: %0d", dpi_neg_byte(8'sd100));
    $display("shortint: %0d", dpi_twice_shortint(-16'sd1234));
    $display("int: %0d", dpi_add_int(2000000000, -2000000001));
    $display("longint: %0d", dpi_mul_longint(64'sd3000000000, 64'sd4));
    $display("real: %0.3f", dpi_half_real(5.25));
    $display("bit: %0d %0d", dpi_not_bit(1'b0), dpi_not_bit(1'b1));
    $display("string in: %0d", dpi_strlen("hello"));
    $display("string out: %s", dpi_word(2));
    c = dpi_new_counter(10);
    n1 = dpi_next(c);
    n2 = dpi_next(c);
    $display("chandle: %0d %0d", n1, n2);
  end
endmodule
