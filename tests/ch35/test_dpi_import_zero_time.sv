/*
:name: test_dpi_import_zero_time
:description: An imported function completes at once and consumes no simulation time, so it can be called in a continuous assignment like a native function (IEEE 1800-2023 Section 35.5.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.1 35.5.1 10.3.2 4.4.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_zero_time.c
:expected_stdout: @test_dpi_import_zero_time.expected
*/
// IEEE 1800-2023 §35.5.1.1: imported functions complete instantly and take
// zero simulation time, like native functions. c_sum loops over its argument
// without any time passing, and c_double drives y through a continuous
// assignment (10.3.2): when x changes at 20, y follows in the same time step,
// which the #0 (an Inactive event, 4.4.2.3) shows.

`timescale 1ns/1ns

module test_dpi_import_zero_time;
  import "DPI-C" function int c_sum(input int n);
  import "DPI-C" function int c_double(input int v);

  int x = 1, y;
  time start;

  assign y = c_double(x);

  initial begin
    #10 start = $time;
    $display("sum=%0d, time passed: %0d", c_sum(100), $time - start);
    #10 x = 4;
    #0 $display("t=%0t: y=%0d", $time, y);
  end
endmodule
