/*
:name: test_vpi_put_value_udp_array_errors
:description: vpi_put_value sets a sequential UDP with no delay whatever the delay of the primitive instance and rejects every delay mode but vpiNoDelay, and vpi_put_value_array writes the elements at once, accepts only vpiPropagateOff and vpiOneValue as flags and rejects formats that the clause does not list (IEEE 1800-2023 Sections 38.34 and 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.35 38.2 28.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_put_value_udp_array_errors.c
:expected_stdout: @test_vpi_put_value_udp_array_errors.expected
*/
// IEEE 1800-2023 §38.34: a value put to a sequential UDP is set with no delay,
// regardless of the delay on the primitive instance, and only vpiNoDelay is
// allowed there; another delay mode is an error, which vpi_chk_error (38.2)
// reports. The primitive udp_hold has the delay 10: at time 5 its inputs take
// the values that set q to 1 at time 15, and at time 6 the application puts 0
// on the UDP instance, which q has at once. The event the primitive scheduled
// still sets q at 15, whatever was put.
// §38.35: vpi_put_value_array has the effect of vpiNoDelay, so the elements
// have the new values when the call returns; its flags may be vpiPropagateOff
// or vpiOneValue, and a format that 38.35 does not list is an error. Each
// illegal call is followed at once by vpi_chk_error.

`timescale 1ns/1ns

primitive udp_hold (q, d, en);
  output q;
  reg q;
  input d, en;
  table
    0 1 : ? : 0;
    1 1 : ? : 1;
    ? 0 : ? : -;
  endtable
endprimitive

module test_vpi_put_value_udp_array_errors;
  reg d = 1'b0, en = 1'b0, q;
  int arr [0:3];

  udp_hold #10 g(q, d, en);

  initial begin
    #5 d = 1'b1;
    en = 1'b1;
    #1 $vt_udp_put;
    $display("%0t: q after the vpiNoDelay put: %b", $time, q);
    #1 $vt_udp_error;
    #3;
    $vt_array_ok(0);
    $display("array after a bulk put: %0d %0d %0d %0d",
             arr[0], arr[1], arr[2], arr[3]);
    $vt_array_ok(1);
    $display("array with vpiPropagateOff: %0d %0d %0d %0d",
             arr[0], arr[1], arr[2], arr[3]);
    $vt_array_ok(2);
    $display("array with vpiOneValue: %0d %0d %0d %0d",
             arr[0], arr[1], arr[2], arr[3]);
    $vt_array_errors;
    $vt_array_ok(3);
    $display("array after the errors: %0d %0d %0d %0d",
             arr[0], arr[1], arr[2], arr[3]);
    #10 $display("%0t: q after the primitive delay: %b", $time, q);
  end
endmodule
