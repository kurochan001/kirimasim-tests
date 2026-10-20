/*
:name: test_pli_read_write_synch_write
:description: A cbReadWriteSynch callback runs in the Pre-NBA or the Post-NBA region, after the blocking assignments of its time step, and a value it writes wakes the design's processes in the same time step (IEEE 1800-2023 Section 4.4.3.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.4 4.4.3.3 4.10 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_read_write_synch_write.c
:expected_stdout: @test_pli_read_write_synch_write.expected
*/
// IEEE 1800-2023 §4.10 (Table 4-1): a cbReadWriteSynch callback runs in the
// Pre-NBA (4.4.3.3) or the Post-NBA region (4.4.3.4), both of which come
// after the Active region and allow PLI applications to write values and
// create events. $vt_register, called at 0, registers one for time 10. At 10
// it sees the 1 that a blocking assignment gave a, and writes 7 to w; the
// process waiting for a change of w runs in the same time step. Which of the
// two regions it is, the test does not show: it reads nothing that a
// nonblocking assignment sets.

`timescale 1ns/1ns

module test_pli_read_write_synch_write;
  int a = 0, w = 0;

  initial begin
    $vt_register;
    #10 a = 1;
  end

  initial begin
    @(w);
    $display("design at %0t: w=%0d", $time, w);
  end
endmodule
