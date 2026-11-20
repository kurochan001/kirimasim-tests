/*
:name: test_strobeb_strobeo_four_state_end_of_step
:description: $strobeb and $strobeo print four-state arguments in binary or octal with the values they have at the end of the time step, after a write from the calling process after #0 and from a process woken by a nonblocking update (IEEE 1800-2023 Section 21.2.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.2 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_strobeb_strobeo_four_state_end_of_step.expected
*/
// IEEE 1800-2023 §21.2.2: $strobeb and $strobeo take their arguments like
// $display, an argument without a format being shown in binary or octal,
// and print at the end of the current time step, when all of its events
// have occurred. §21.2.1.3: binary shows each bit as 0, 1, x or z; an octal
// digit whose bits are all x or all z is x or z, one with some x bits is X,
// and one with some z bits and no x bit is Z.
// Time 1: after $strobeb the process writes k, and after #0, which resumes
// later in the same step, bit 0 of v. Time 2: after $strobeo the process
// schedules v <= 7'o123, which wakes the always procedure that sets k to
// 3'b1z0; the %b of the call applies to k. Time 3: after $strobeo the
// process writes v and k at once. The $display line of each step shows the
// values at the call and comes before the strobe line of that step. Only
// one strobe task is called in each time step, so the order is fixed.

module test_strobeb_strobeo_four_state_end_of_step;
  logic [6:0] v = 7'd0;
  logic [2:0] k = 3'd0;

  always @(v) if (v === 7'o123) k = 3'b1z0;

  initial begin
    #1;
    v = 7'b10xz110;
    $strobeb("b v=", v, " k=", k);
    $display("t1 call v=%b k=%b", v, k);
    k = 3'bz10;
    #0 v[0] = 1'b1;
    #1;
    $strobeo("o v=", v, " k=%b", k);
    $display("t2 call v=%b k=%b", v, k);
    v <= 7'o123;
    #1;
    $strobeo("o2 v=", v, " k=", k);
    $display("t3 call v=%b k=%b", v, k);
    v = 7'bx0z_1zz1;
    k = 3'bxxx;
  end
endmodule
