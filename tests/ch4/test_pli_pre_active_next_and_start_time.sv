/*
:name: test_pli_pre_active_next_and_start_time
:description: cbNextSimTime and cbAtStartOfSimTime callbacks run in the Pre-Active region, before the design's events of their time step, and a value they write is seen by the design's processes of that step and wakes the processes waiting for it (IEEE 1800-2023 Section 4.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.10 4.4.3.2 38.36.2 38.34
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_pre_active_next_and_start_time.c
:expected_stdout: @test_pli_pre_active_next_and_start_time.expected
*/
// IEEE 1800-2023 §4.10, Table 4-1: cbNextSimTime and cbAtStartOfSimTime
// callbacks run in the Pre-Active region. §4.4.3.2: that region lets a PLI
// application read and write values and create events before the Active
// events of the time step. §38.36.2: cbNextSimTime runs before the events of
// the next time step that has events, and cbAtStartOfSimTime before the
// events of a given time. §38.34: vpiNoDelay writes a value at once.
// $vt_register, called at 0, registers a cbNextSimTime callback, which runs
// at 10, and a cbAtStartOfSimTime callback for 20. At 10 the callback sees a
// still 0, as the design sets it later in that step, and writes v = 7, which
// the design's process that resumes at 10 prints. At 20 the other callback
// sees b still 0 and writes w = 5: the design prints it at 20, and the write
// wakes the process waiting for w, which records the value and the time 20.

`timescale 1ns/1ns

module test_pli_pre_active_next_and_start_time;
  int a = 0, b = 0, v = 0, w = 0, w_copy = 0, w_time = -1;

  always @(w) begin
    w_copy = w;
    w_time = $time;
  end

  initial begin
    $vt_register;
    #10;
    $display("design at 10: v=%0d", v);
    a = 1;
    #10;
    $display("design at 20: w=%0d", w);
    b = 1;
    #5 $display("design at 25: w_copy=%0d w_time=%0d", w_copy, w_time);
    #5 $finish;
  end
endmodule
