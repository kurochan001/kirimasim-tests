/*
:name: test_vpi_gate_delays
:description: vpi_get_delays reads the rise and fall delays of a gate in the time unit of its module, and after vpi_put_delays sets new ones, the gate's output changes with the new delays (IEEE 1800-2023 Sections 38.10 and 38.32)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.10 38.32 28.16 37.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_gate_delays.c
:expected_stdout: @test_vpi_gate_delays.expected
*/
// IEEE 1800-2023 §38.10: for a primitive, vpi_get_delays reads 2 or 3 delays,
// here the rise and fall delays 3 and 5 of g1 (28.16), as vpiScaledRealTime
// in the time unit of the module, 1 ns. §38.32: vpi_put_delays sets them, here
// to 7 and 9, in the same order. $vt_delays runs at 8, after the gate's output
// has settled to 0; then the output rises 7 after a and b become 1 at 10, and
// falls 9 after b becomes 0 at 30. The gate is found by its instance name
// (37.35).

`timescale 1ns/1ns

module test_vpi_gate_delays;
  logic a = 0, b = 0;
  wire y;

  and #(3, 5) g1 (y, a, b);

  always @(y) if ($time > 8) $display("%0d: y = %b", $time, y);

  initial begin
    #8 $vt_delays;
    #2 a = 1;
    b = 1;
    #20 b = 0;
    #20 $finish;
  end
endmodule
