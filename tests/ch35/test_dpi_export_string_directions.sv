/*
:name: test_dpi_export_string_directions
:description: An exported function called from C reads an input string through a const char* without changing its characters, writes a valid string pointer into an output const char**, and changes an inout string by writing a new pointer while the C storage it got keeps its characters (IEEE 1800-2023 Section 35.5.4, H.8.10)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_string_directions.c
:expected_stdout: @test_dpi_export_string_directions.expected
*/
// IEEE 1800-2023 §35.5.4: a function declared with export "DPI-C" can be
// called from C. H.8.10: the direction of a string argument is that of the
// pointer, not of the characters. For an exported function, an input string
// is a const char* whose characters SystemVerilog only reads; an output
// string is a const char** with no meaningful value on entry, into which
// SystemVerilog writes the address of a valid string; an inout string is a
// const char** holding the address of the caller's own initialized string,
// which SystemVerilog only reads, and when SystemVerilog changes the string
// it writes a new address there. C may not free these strings or rely on
// how long they live, so it copies them into its own buffers at once.
//
// c_run calls sv_strings with "in", an output pointer set to NULL, and an
// inout pointer to its own buffer holding "mine". sv_strings prints what it
// got, sets the output to the input with "!" added and the inout to its old
// value with "+" added. C then prints the copies of the two results, whether
// the inout pointer was changed, and its own two buffers, which still hold
// their characters.

module test_dpi_export_string_directions;
  import "DPI-C" context function void c_run();
  export "DPI-C" function sv_strings;

  function void sv_strings(input string i, output string o, inout string io);
    $display("sv_strings: input \"%s\", inout \"%s\"", i, io);
    o = {i, "!"};
    io = {io, "+"};
  endfunction

  initial c_run();
endmodule
