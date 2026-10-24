/*
:name: test_vpi_value_change_strength_time_objtype
:description: A cbValueChange callback registered with vpiStrengthVal runs when the strength of a net changes while its logic value stays 1 and gets the value with its strength, one with vpiTimeVal gets a time variable in two integers, and one with vpiObjTypeVal gets the value in the format closest to the object (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.15 28.11 38.36.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_value_change_strength_time_objtype.c
:expected_stdout: @test_vpi_value_change_strength_time_objtype.expected
*/
// IEEE 1800-2023 §38.36.1: a cbValueChange callback registered with the
// format vpiStrengthVal runs whenever the strength of its object changes,
// also when the logic value does not change, and gets the value with its
// strength (Table 38-5); a callback with another format runs on a change of
// the value. With vpiTimeVal the value is given in two integers, and with
// vpiObjTypeVal in the closest format of the object (vpiIntVal for an
// integer, vpiRealVal for a real, vpiVectorVal for a vector, 38.15). The net n
// has a weak 1 driver and a strong driver that drives 1 while en is 1 and z
// otherwise (28.11), so n is 1 all the time and only its strength changes,
// at 10 and 12. In a cbAfterDelay callback at 1 (38.36.2), registered at the
// start of the simulation (38.36.3), the application registers on n one
// callback with vpiStrengthVal and one with vpiBinStrVal, one with vpiTimeVal
// on the time variable tv, which changes at 14, and ones with vpiObjTypeVal
// on iv, rv and vec, which change at 16, 17 and 18.
// Icarus Verilog 13.0 does not support vpiStrengthVal, vpiTimeVal and
// vpiObjTypeVal in a cbValueChange callback on a variable or a net, and
// stops.

`timescale 1ns/1ns

module test_vpi_value_change_strength_time_objtype;
  logic en;
  wire n;
  time tv;
  integer iv;
  real rv;
  logic [11:0] vec;

  assign (weak0, weak1) n = 1'b1;
  assign (strong0, strong1) n = en ? 1'b1 : 1'bz;

  initial begin
    en = 0;
    tv = 0;
    iv = 0;
    rv = 0.0;
    vec = 0;
    #10 en = 1;
    #2 en = 0;
    #2 tv = 64'h0000_0002_0000_0005;
    #2 iv = -7;
    #1 rv = 1.25;
    #1 vec = 12'h5a3;
    #1 $finish;
  end
endmodule
