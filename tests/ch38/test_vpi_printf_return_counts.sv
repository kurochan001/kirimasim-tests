/*
:name: test_vpi_printf_return_counts
:description: vpi_printf and vpi_vprintf format like C printf and return the number of characters written, including field widths, %% and an empty result, and vpi_flush returns 0 between the two parts of a line (IEEE 1800-2023 Sections 38.30, 38.41 and 38.5)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.30 38.41 38.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_printf_return_counts.c
:expected_stdout: @test_vpi_printf_return_counts.expected
*/
// IEEE 1800-2023 §38.30: vpi_printf writes to the output channel of the tool,
// with a format string of the C printf routine, and returns the number of
// characters written. §38.41: vpi_vprintf does the same with a varargs list
// that the caller has already started. §38.5: vpi_flush flushes the output
// channel and returns 0 on success. At the start of the simulation the VPI
// application writes each line twice, with vpi_printf and then with
// vpi_vprintf through a varargs wrapper: field widths, a left-justified field,
// %x, %o, %c, %%, a precision, %e, two lines in one call and an empty result.
// It then prints the counts, and writes one line in two parts with vpi_flush
// between them.

module test_vpi_printf_return_counts;
  initial #1 $display("design: done");
endmodule
