/*
:name: test_vpi_string_buffers
:description: vpi_get_str puts every string in one temporary buffer that the next call overwrites, vpi_get_value puts its strings in another buffer that its next call overwrites, and a call of either routine leaves the string of the other unchanged (IEEE 1800-2023 Sections 38.11 and 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.11 38.15 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_string_buffers.c
:expected_stdout: @test_vpi_string_buffers.expected
*/
// IEEE 1800-2023 §38.11: vpi_get_str places its string in a temporary buffer
// that every call of the routine uses, so a string needed after the next call
// has to be copied; the strings that vpi_get_value returns through
// s_vpi_value use a different buffer. §38.15: that buffer of vpi_get_value
// is overwritten by each of its calls. In a cbAfterDelay callback at 1
// (38.36.2), registered at the start of the simulation (38.36.3), the
// application keeps the pointer returned by one call and prints the text it
// points to after a call of the same routine for another object, and after a
// call of the other routine. The names of alpha and beta differ, and so do
// their values in vpiBinStrVal.

`timescale 1ns/1ns

module test_vpi_string_buffers;
  logic [3:0] alpha, beta;

  initial begin
    alpha = 4'b1010;
    beta = 4'b0101;
    #2 $finish;
  end
endmodule
