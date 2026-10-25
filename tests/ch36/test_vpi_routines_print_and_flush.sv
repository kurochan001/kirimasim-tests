/*
:name: test_vpi_routines_print_and_flush
:description: the printing routines of Table 36-9 do what it lists: vpi_printf and vpi_vprintf write text formatted as by C printf to the output of the simulator and return the number of characters written, and vpi_flush flushes that output and returns 0 (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.30 38.41 38.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_print_and_flush.c
:expected_stdout: @test_vpi_routines_print_and_flush.expected
*/
// IEEE 1800-2023 §36.11, Table 36-9: vpi_printf writes to the output channel
// of the tool that invoked the application and to the current log file,
// vpi_vprintf does the same with a varargs list that is already started, and
// vpi_flush flushes the output buffers of the simulator. §38.30, §38.41: the
// format string is that of C printf, and the routines return the number of
// characters written. §38.5: vpi_flush returns 0 on success.
// At the start of simulation the application writes a line with vpi_printf
// and one through a variadic function of its own that passes its va_list to
// vpi_vprintf, both with a decimal, a string and a hexadecimal conversion,
// then calls vpi_flush and prints the three results. The design prints a line
// at time 1, after them.

module test_vpi_routines_print_and_flush;
  initial #1 $display("design: done");
endmodule
