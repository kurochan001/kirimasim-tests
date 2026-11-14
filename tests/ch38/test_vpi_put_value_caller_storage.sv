/*
:name: test_vpi_put_value_caller_storage
:description: vpi_put_value takes a delayed value from an s_vpi_value, the storage it points to and an s_vpi_time that the application allocates and overwrites right after the call, in the binary, octal, decimal and hex string, scalar, integer, real, string and vector formats of Table 38-3 (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_put_value_caller_storage.c
:expected_stdout: @test_vpi_put_value_caller_storage.expected
*/
// IEEE 1800-2023 §38.34: the application allocates the s_vpi_value that
// holds the value to set, any storage the value union points to, and the
// s_vpi_time that holds the delay, and the value has one of the formats of
// Table 38-3 (38.15). The storage belongs to the application, so the value
// and the delay are those the structures hold during the call, even when the
// event comes later and the application has changed or given up the
// structures in between.
//
// At time 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application puts a value into each object with
// vpiInertialDelay and a delay of 4: b as the binary string "10x0z101", o
// as the octal string "7x5", d as the decimal string "201", h as the hex
// string "be0f", st as the string "wxyz", s as vpi1, i as -12345, r as 6.125
// and vec from the words aval 0x01234567, bval 0 and aval 0x8f, bval 0x0f.
// All the puts use one value structure, one string buffer, one pair of
// vector words and one delay structure, so each put overwrites what the one
// before it passed, and after the last put the application overwrites them
// all, the delay with 8. The design prints at 4, before the events at 5, and
// at 6, after them.

`timescale 1ns/1ns

module test_vpi_put_value_caller_storage;
  logic [7:0] b;
  logic [8:0] o;
  logic [7:0] d;
  logic [15:0] h;
  logic s;
  int i;
  real r;
  logic [31:0] st;
  logic [39:0] vec;

  initial begin
    #4 $display("4: b=%b i=%0d r=%.3f", b, i, r);
    #2 $display("6: b=%b o=%o d=%0d h=%h s=%b i=%0d r=%.3f st=%s vec=%h",
                b, o, d, h, s, i, r, st, vec);
    $finish;
  end
endmodule
