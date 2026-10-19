/*
:name: test_vpi_put_value_delay_modes
:description: vpi_put_value schedules values with inertial, transport and pure transport delay, removing different earlier events, and sets a value at once with vpiNoDelay (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_delay_modes.c
:expected_stdout: @test_vpi_put_value_delay_modes.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value with vpiInertialDelay removes every
// event already scheduled on the object, vpiTransportDelay removes the events
// scheduled later than the new one, vpiPureTransportDelay removes none, and
// vpiNoDelay sets the value at once. $vt_put(var, value, delay, mode) calls it,
// with the delay in the time unit of the variable. At 10, a and b get 1 after 5
// and then 0 after 8; c and d get 0 after 8 and then 1 after 5. Only a and d
// keep both events, and b never changes. Icarus Verilog 13.0 keeps every
// scheduled event in all three delay modes, and Verilator 5.052 does not
// support user-defined system tasks.

`timescale 1ns/1ns

module test_vpi_put_value_delay_modes;
  reg a, b, c, d, e;

  initial begin
    a = 0; b = 0; c = 0; d = 0; e = 0;
    #10;
    $vt_put(a, 1, 5, 3);  $vt_put(a, 0, 8, 3);
    $vt_put(b, 1, 5, 1);  $vt_put(b, 0, 8, 1);
    $vt_put(c, 0, 8, 2);  $vt_put(c, 1, 5, 2);
    $vt_put(d, 0, 8, 3);  $vt_put(d, 1, 5, 3);
    $vt_put(e, 1, 0, 0);
    $display("%0d: e=%b right after the call", $time, e);
    #20 $finish;
  end

  always @(a or b or c or d) if ($time > 10) $display("%0d: a=%b b=%b c=%b d=%b", $time, a, b, c, d);
endmodule
