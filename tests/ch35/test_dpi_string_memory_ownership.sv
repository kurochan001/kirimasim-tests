/*
:name: test_dpi_string_memory_ownership
:description: Strings that C hands to SystemVerilog stay in C's memory, which C reuses or frees, so SystemVerilog keeps copies of their characters, and C copies a SystemVerilog string into its own memory to keep it (IEEE 1800-2023 Section 35.5.1.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.4 H.6.6 H.8.10 H.8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_string_memory_ownership.c
:expected_stdout: @test_dpi_string_memory_ownership.expected
*/
// IEEE 1800-2023 §35.5.1.4, H.6.6: the memory of the C code and that of
// SystemVerilog are disjoint, and each side frees only what it allocated.
// H.8.10: when C gives an inout string a new pointer, SystemVerilog copies
// the characters into its own memory and never frees C's storage; C may not
// free an input string or assume how long it lives. c_bracket returns its
// result in one static buffer, which the next call overwrites; c_make returns
// a string it allocated (H.8.9), which it frees at its next call, and c_drop
// overwrites and frees the last one; c_keep copies its input into memory of
// its own, and c_kept returns that copy after the SystemVerilog variable has
// changed. Each string variable keeps the value it was given.

module test_dpi_string_memory_ownership;
  import "DPI-C" function void c_bracket(inout string s);
  import "DPI-C" function string c_make(input int n);
  import "DPI-C" function void c_drop();
  import "DPI-C" function void c_keep(input string s);
  import "DPI-C" function string c_kept();

  string a = "one", b = "two", m1, m2, note = "first";

  initial begin
    c_bracket(a);
    c_bracket(b);
    $display("inout: a=%s b=%s", a, b);
    m1 = c_make(1);
    m2 = c_make(2);
    c_drop();
    $display("results: m1=%s m2=%s", m1, m2);
    c_keep(note);
    note = "second";
    $display("C kept \"%s\", SystemVerilog now has \"%s\"", c_kept(), note);
  end
endmodule
