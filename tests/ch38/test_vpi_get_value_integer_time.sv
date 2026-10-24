/*
:name: test_vpi_get_value_integer_time
:description: vpi_get_value with vpiObjTypeVal gives an integer variable as vpiIntVal and a time variable as vpiTimeVal with vpiSimTime, and with vpiTimeVal gives a time variable in its high and low 32 bits (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.36.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_integer_time.c
:expected_stdout: @test_vpi_get_value_integer_time.expected
*/
// IEEE 1800-2023 §38.15: when the format field is vpiObjTypeVal,
// vpi_get_value fills in the value in the format that fits the object and
// changes the format field to it: vpiIntVal for an integer, and vpiTimeVal
// with the time type vpiSimTime for a time variable. With vpiTimeVal
// (Table 38-3), value.time holds the value in two 32-bit integers, high and
// low. The application reads the integer i and the time variable t in a
// cbAfterDelay callback at 1 (38.36.2), registered at the start of the
// simulation (38.36.3), first with vpiObjTypeVal and then t with vpiTimeVal.
// Icarus Verilog 13.0 gives both variables as vpiVectorVal and stops with an
// internal error on vpiTimeVal for a time variable; Verilator 5.052 supports
// neither format.

`timescale 1ns/1ns

module test_vpi_get_value_integer_time;
  integer i;
  time t;

  initial begin
    i = -5;
    t = 64'h0000_0002_0000_0007;
    #2 $finish;
  end
endmodule
