/*
:name: test_pli_end_of_time_write
:description: A cbAtEndOfSimTime callback runs in the Pre-Postponed region, after the nonblocking updates, and a value it writes starts another iteration of the time step, which a cbReadOnlySynch callback in the Postponed region then sees (IEEE 1800-2023 Section 4.4.3.9)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.9 4.4.3.10 4.10 4.5 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_end_of_time_write.c
:expected_stdout: @test_pli_end_of_time_write.expected
*/
// IEEE 1800-2023 §4.4.3.9: the Pre-Postponed region comes after all other
// regions but the Postponed one, and PLI applications can still write values
// and create events there; §4.10 (Table 4-1) places cbAtEndOfSimTime there.
// As it is an iterative region (4.5), the events it creates run in the same
// time step. §4.4.3.10: cbReadOnlySynch callbacks run last, in the Postponed
// region. $vt_register, called at 0, registers both for time 10. At 10 the
// design sets b with a nonblocking assignment; the cbAtEndOfSimTime callback
// sees b = 1 and writes 3 to w, the always procedure sets c to twice w, and
// the cbReadOnlySynch callback sees w = 3 and c = 6.

`timescale 1ns/1ns

module test_pli_end_of_time_write;
  int b = 0, w = 0, c = 0;

  initial begin
    $vt_register;
    #10 b <= 1;
  end

  always @(w) begin
    c = 2 * w;
    $display("design at %0t: c=%0d", $time, c);
  end
endmodule
