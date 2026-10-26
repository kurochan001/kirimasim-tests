/*
:name: test_dpi_input_copy_const_and_lifetime
:description: An imported function takes input arguments with const qualification, reads them without changing the SystemVerilog actuals, and copies the values it must keep into its own storage, because a by-reference input argument's pointer is not valid across calls (IEEE 1800-2023 Sections H.6, H.6.2 and H.8.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.6 H.6.2 H.8.4 H.8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_input_copy_const_and_lifetime.c
:expected_stdout: @test_dpi_input_copy_const_and_lifetime.expected
*/
// IEEE 1800-2023 H.6: a SystemVerilog compiler cannot change the formals of
// an imported C routine, and H.6.2: foreign code must not modify an input
// formal argument. H.8.4: a by-reference argument is a pointer to the
// actual, and C must not assume that it stays valid across calls; a value
// kept across calls is copied into C storage. H.8.7: imported input
// arguments that are passed by reference carry a const qualifier, here the
// const char* of the string and the const svLogicVecVal* of the 64-bit
// vector.
//
// c_keep is called twice. The first call copies the string "first", the
// longint 11 and the packed value 0123456789abcdef into its own storage and
// prints them; the test then assigns new actuals. The second call prints the
// new values and the copies, which still hold the first values, and returns
// 2. The SystemVerilog actuals after both calls are still the second values,
// because C only read its input arguments.

`timescale 1ns/1ns

module test_dpi_input_copy_const_and_lifetime;
  import "DPI-C" function void c_keep(input string s, input longint n,
                                      input logic [63:0] v, output int o);

  string s = "first";
  longint n = 11;
  logic [63:0] v = 64'h0123456789ABCDEF;
  int o;

  initial begin
    c_keep(s, n, v, o);
    s = "second";
    n = 12;
    v = 64'h0;
    c_keep(s, n, v, o);
    $display("after %s %0d %016h o=%0d", s, n, v, o);
  end
endmodule
