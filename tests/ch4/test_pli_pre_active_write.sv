/*
:name: test_pli_pre_active_write
:description: A cbAfterDelay callback runs in the Pre-Active region, so it sees the values from before the design's events of its time step, and a value it writes is there when the design's processes of that time step run (IEEE 1800-2023 Section 4.4.3.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.2 4.10 38.36.2 38.34
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_pre_active_write.c
:expected_stdout: @test_pli_pre_active_write.expected
*/
// IEEE 1800-2023 §4.4.3.2: the Pre-Active region lets PLI applications read
// and write values and create events before the events of the Active region
// are evaluated, and §4.10 (Table 4-1) places cbAfterDelay callbacks there.
// $vt_register, called at 0, registers one with a delay of 10 (38.36.2). At
// 10 the callback sees a still 0, as the design sets it only in that time
// step, and writes 5 to v with vpiNoDelay (38.34); the design's process that
// resumes at 10 then prints the 5.

`timescale 1ns/1ns

module test_pli_pre_active_write;
  int a = 0, v = 0;

  initial begin
    $vt_register;
    #10;
    $display("design at %0t: v=%0d", $time, v);
    a = 1;
  end
endmodule
