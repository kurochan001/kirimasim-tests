/*
:name: test_vpi_mcd_printf_signature_format
:description: vpi_mcd_printf takes a PLI_UINT32 descriptor, a PLI_BYTE8 * format and further arguments, returns a PLI_INT32, writes text formatted as C fprintf formats it and returns the number of characters written (IEEE 1800-2023 Section 38.28)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.28
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_printf_signature_format.c
:expected_stdout: @test_vpi_mcd_printf_signature_format.expected
*/
// IEEE 1800-2023 §38.28: the routine vpi_mcd_printf has a PLI_UINT32
// multichannel descriptor as its first argument and a PLI_BYTE8 * format as
// its second, followed by the values the format converts, and it returns a
// PLI_INT32, the number of characters written. The format has the meaning
// of a C fprintf format. Bit 0 of a descriptor selects channel 1, the output
// of the tool.
//
// At the start of the simulation the application compares the type of the
// address of the routine, and the type of a call of it, with the types of
// the clause; each comparison prints 1 when the types are the same. It then
// makes six calls with the descriptor 1: five write a line each, with flags,
// field widths, precisions, a width taken from an argument, and the integer,
// unsigned, hexadecimal, octal, character, string, percent, fixed and
// exponent conversions, and one has an empty format, which writes nothing.
// It prints the six counts the calls return: each is the length of the text
// of its line, newline included, and 0 for the empty format. The release
// 13.0 of Icarus Verilog declares the format argument as a const char *, so
// the first comparison prints 0 there; the expected output follows the
// clause.

module test_vpi_mcd_printf_signature_format;
  initial #1 $finish;
endmodule
