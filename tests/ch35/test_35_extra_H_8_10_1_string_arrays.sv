/*
:name: test_35_extra_H_8_10_1_string_arrays
:description: String arrays of an imported function are const char** in C for input, output and inout directions, and C reads and rewrites their elements without an extra level of indirection for outputs (IEEE 1800-2023 Section H.8.10.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.8.10.1 H.7.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_35_extra_H_8_10_1_string_arrays.c
:expected_stdout: @test_35_extra_H_8_10_1_string_arrays.expected
*/
// IEEE 1800-2023 §H.8.10.1: string members of aggregate arguments are
// const char*, with the same ownership and lifetime rules as a stand-alone
// string, and an array of strings is const char** for every direction, with
// no extra level of indirection for an output or inout array (H.7.8).
//
// The three imports take a fixed-size unpacked array of three strings. s_in
// reads the characters of the input elements, s_out writes new string
// pointers into the output array, and s_inout reads one element and writes
// another through the same const char** parameter. SystemVerilog sees the
// strings that C wrote. The C code flushes standard output after each printf,
// so its lines keep their place among the lines of $display.
module test_35_extra_H_8_10_1_string_arrays;
  import "DPI-C" function void s_in(input string a[3]);
  import "DPI-C" function void s_out(output string a[3]);
  import "DPI-C" function void s_inout(inout string a[3]);

  string x[3] = '{"alpha", "beta", "gamma"};

  initial begin
    s_in(x);
    s_out(x);
    $display("out %s %s %s", x[0], x[1], x[2]);
    s_inout(x);
    $display("inout %s %s %s", x[0], x[1], x[2]);
  end
endmodule
