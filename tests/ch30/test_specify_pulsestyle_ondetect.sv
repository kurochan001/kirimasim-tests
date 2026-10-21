/*
:name: test_specify_pulsestyle_ondetect
:description: A pulse that is filtered to x shows x from the time it is detected on an output declared pulsestyle_ondetect, and from the scheduled time of its leading edge on one declared pulsestyle_onevent; a wider pulse passes on both (IEEE 1800-2023 Section 30.7.4.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7.4.1 30.7.1 30.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_pulsestyle_ondetect.expected
*/
// IEEE 1800-2023 §30.7: a pulse on a path output narrower than the error limit
// but not narrower than the reject limit is filtered to x. §30.7.1:
// PATHPULSE$ = (1, 5) gives every path of the module a reject limit of 1 and
// an error limit of 5. §30.7.4.1: with on-event filtering, selected for z by
// pulsestyle_onevent, the leading edge becomes a change to x at its own
// scheduled time and the trailing edge a change from x; with on-detect,
// selected for y by pulsestyle_ondetect, the change to x happens at once when
// the pulse is detected. Both paths have delay 6. The input pulse from 10 to
// 13 would reach the outputs from 16 to 19, a pulse of 3: it is detected at
// 13, when the trailing edge is scheduled, so y is x from 13 and z from 16,
// and both are 0 again at 19. The pulse from 30 to 37 is 7 wide and passes
// on both, from 36 to 43. Changes before 10 are not logged. Icarus Verilog
// 13.0 does not support the pulse style declarations and ignores PATHPULSE$:
// it rejects the pulse of 3 on both outputs.

`timescale 1ns/1ns

module test_specify_pulsestyle_ondetect_cell (input a, output y, output z);
  buf (y, a);
  buf (z, a);
  specify
    pulsestyle_ondetect y;
    pulsestyle_onevent z;
    (a => y) = 6;
    (a => z) = 6;
    specparam PATHPULSE$ = (1, 5);
  endspecify
endmodule

module test_specify_pulsestyle_ondetect;
  reg a = 0;
  wire y, z;
  string log_y = "", log_z = "";

  test_specify_pulsestyle_ondetect_cell u(a, y, z);

  always @(y) if ($time >= 10) log_y = {log_y, $sformatf(" %0t:%b", $time, y)};
  always @(z) if ($time >= 10) log_z = {log_z, $sformatf(" %0t:%b", $time, z)};

  initial begin
    #10 a = 1;
    #3 a = 0;           // 13
    #17 a = 1;          // 30
    #7 a = 0;           // 37
    #20 $display("ondetect y:%s", log_y);
    $display("onevent z:%s", log_z);
  end
endmodule
