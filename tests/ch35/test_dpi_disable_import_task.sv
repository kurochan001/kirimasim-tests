/*
:name: test_dpi_disable_import_task
:description: Disabling a block during an exported task called from an imported task makes the export return 1, and the import acknowledges the disable by returning 1 (IEEE 1800-2023 Section 35.9)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9 35.8 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_disable_import_task.c
:expected_stdout: @test_dpi_disable_import_task.expected
*/
// IEEE 1800-2023 §35.9: a disable can target a block that is running a call
// chain through C. The exported task called from the import then returns 1,
// svIsDisabledState() returns 1, and the imported task acknowledges the disable
// by returning 1 without calling further exports. The block worker is disabled
// at 25, while its third step waits; the C code reports the step and returns,
// and the statement after the import call does not run. Verilator 5.052 does
// not support timing controls in exported tasks, and Icarus Verilog 13.0 has no
// DPI.

`timescale 1ns/1ns

module test_dpi_disable_import_task;
  import "DPI-C" context task dpi_tick_loop(input int n);
  export "DPI-C" task sv_tick;

  task sv_tick(input int i);
    #10 $display("%0d: tick %0d", $time, i);
  endtask

  initial begin : worker
    dpi_tick_loop(5);
    $display("%0d: loop finished", $time);
  end

  initial begin
    #25 disable worker;
    #1 $display("%0d: after the disable", $time);
  end
endmodule
