/*
:name: test_time_literal_every_unit
:description: A time literal is an integer or a fixed-point number followed by one of the units fs, ps, ns, us, ms and s, and its value is scaled to the current time unit (IEEE 1800-2023 Section 5.8)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.8 3.14.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literal_every_unit.expected
*/
// IEEE 1800-2023 §5.8: a time literal is a number in integer or fixed-point
// form followed, without a space, by a time unit: fs, ps, ns, us, ms or s.
// It is a realtime value scaled to the current time unit.
// The module sets its time unit to 1ns and its precision to 1fs (§3.14.2.2),
// so every literal here is a whole number of precision steps. Each unit is
// used once with an integer and once with a fixed-point number, and the
// realtime values are printed in nanoseconds.

module test_time_literal_every_unit;
  timeunit 1ns;
  timeprecision 1fs;
  realtime r[12];

  initial begin
    r = '{3fs, 4.0fs, 7ps, 2.5ps, 4ns, 0.5ns, 2us, 1.5us, 3ms, 0.25ms, 1s, 0.5s};
    $display("fs: %0.7f %0.7f", r[0], r[1]);
    $display("ps: %0.4f %0.4f", r[2], r[3]);
    $display("ns: %0.1f %0.1f", r[4], r[5]);
    $display("us: %0.1f %0.1f", r[6], r[7]);
    $display("ms: %0.1f %0.1f", r[8], r[9]);
    $display("s: %0.1f %0.1f", r[10], r[11]);
  end
endmodule
