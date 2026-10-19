/*
:name: test_specify_pulse_filtering
:description: Pulses shorter than the path delay are rejected by default, and PATHPULSE$ sets reject and error limits that pass pulses or turn them into x (IEEE 1800-2023 Section 30.7)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7 30.7.1 30.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_pulse_filtering.expected
*/
// IEEE 1800-2023 §30.7: two output transitions closer together than the path
// delay form a pulse. By default the reject and error limits equal the delay, so
// any such pulse is rejected. §30.7.1: PATHPULSE$b$z = (2, 4) sets a reject
// limit of 2 and an error limit of 4 for the path from b to z: a pulse shorter
// than 2 is rejected, one of at least 2 but less than 4 becomes x, and one of 4
// or more passes. §30.7.4.1: by default (on-event) the x starts and ends at the
// times the edges of the pulse would have reached the output. Transitions
// before time 10 are not printed.

`timescale 1ns/1ns

module specify_pulse_bufs(output y, output z, input a, input b);
  buf (y, a);
  buf (z, b);
  specify
    (a => y) = 6;
    (b => z) = 6;
    specparam PATHPULSE$b$z = (2, 4);
  endspecify
endmodule

module test_specify_pulse_filtering;
  reg a = 0, b = 0;
  wire y, z;

  specify_pulse_bufs u(y, z, a, b);

  always @(y or z) if ($time >= 10) $display("%0d: y=%b z=%b", $time, y, z);

  initial begin
    #10 a = 1;
    #3 a = 0;      // 13: a pulse of 3 on y: rejected
    #7 a = 1;      // 20
    #10 a = 0;     // 30: a pulse of 10: y at 26 and 36
    #20 b = 1;     // 50
    #1 b = 0;      // 51: a pulse of 1 on z: rejected
    #9 b = 1;      // 60
    #3 b = 0;      // 63: a pulse of 3: x from 66 to 69
    #17 b = 1;     // 80
    #5 b = 0;      // 85: a pulse of 5: z at 86 and 91
    #15 $finish;
  end
endmodule
