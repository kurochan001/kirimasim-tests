/*
:name: test_pli_end_of_time_after_reactive_set
:description: A cbAtEndOfSimTime callback runs in the Pre-Postponed region, after the active and the reactive region sets of its time step are empty, and a value it writes starts another iteration of both sets before the Postponed region (IEEE 1800-2023 Section 4.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.10 4.4.3.9 4.4.3.10 4.5 38.36.2 24.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_end_of_time_after_reactive_set.c
:expected_stdout: @test_pli_end_of_time_after_reactive_set.expected
*/
// IEEE 1800-2023 §4.10, Table 4-1: a cbAtEndOfSimTime callback runs in the
// Pre-Postponed region. §4.4.3.9: there a PLI application can read and write
// values and create events after all other regions but Postponed. §4.4.3.10
// and §4.5: Pre-Postponed runs only when the regions from Active to
// Post-Re-NBA are empty, and new work it creates makes the time step iterate
// again; a cbReadOnlySynch callback runs in the Postponed region after that.
// §24.3.1: a program process runs in the Reactive region and its
// nonblocking assignments update in the Re-NBA region.
// At 10 the design sets b <= 1. The update wakes a program process, which
// sets p = 2 and q <= 3 and then waits for w. The cbAtEndOfSimTime callback
// for 10 sees b, p and q all set, so it runs after the reactive region set,
// and writes w = 4. That write wakes a module process (c = w + 1) and the
// program process (r = w * 2) in the same time step, and the cbReadOnlySynch
// callback for 10 sees w=4, c=5 and r=8.
// The release 5.052 of Verilator does not support a program declared in a
// module.

`timescale 1ns/1ns

module test_pli_end_of_time_after_reactive_set;
  int b = 0, p = 0, q = 0, w = 0, c = 0, r = 0;

  always @(w) c = w + 1;

  initial begin
    $vt_register;
    #10 b <= 1;
    #10 $finish;
  end

  program prog;
    initial begin
      wait (b == 1);
      p = 2;
      q <= 3;
      @(w);
      r = w * 2;
      #20;
    end
  endprogram
endmodule
