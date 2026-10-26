/*
:name: test_vpi_get_value_preserve
:description: A vector value and a string value read with vpi_get_value stay correct in application storage that holds a copy of every pointed-to member after later vpi_get_value calls (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_preserve.c
:expected_stdout: @test_vpi_get_value_preserve.expected
*/
// IEEE 1800-2023 §38.15: vpi_get_value supplies the storage that the value
// union members str, time, vector, strength and misc point to, and that
// storage is valid only until the next call to vpi_get_value. To keep a
// retrieved value, the application allocates storage and copies the value,
// including the members the union points to: every s_vpi_vecval of a vector,
// or every character of a string.
//
// At time 1 the application reads w (64 bits) as vpiVectorVal and copies its
// two s_vpi_vecval words, and reads st as vpiStringVal and copies the two
// characters. It then reads r as vpiRealVal, x as vpiHexStrVal and w again,
// which may overwrite the storage of the earlier reads, and prints the copies
// to show that they are unchanged.

`timescale 1ns/1ns

module test_vpi_get_value_preserve;
  logic [63:0] w;
  logic [15:0] st;
  real r;
  logic [7:0] x;

  initial begin
    w = 64'h1122334455667788;
    st = 16'h4142;
    r = 2.5;
    x = 8'ha5;
    #1 $vt_read;
    #1 $finish;
  end
endmodule
