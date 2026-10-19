/*
:name: test_dpi_export_task_time
:description: A context imported task can call an exported task that consumes time, and the exported task returns 0 to C when it is not disabled (IEEE 1800-2023 Section 35.8)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.8 35.5.3 35.5.4 35.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_task_time.c
:expected_stdout: @test_dpi_export_task_time.expected
*/
// IEEE 1800-2023 §35.8: SystemVerilog tasks can be exported, and an imported
// task may call one only if it is a context task (35.5.3). An exported task
// returns an int to C, 0 unless a disable is in effect (35.9); an imported task
// is an int function in C (35.5.4) and returns 0 here. The exported task waits
// before it prints, so time passes inside the import call, and SystemVerilog
// continues after the import has returned. Verilator 5.052 does not support
// timing controls in exported tasks, and Icarus Verilog 13.0 has no DPI.

`timescale 1ns/1ns

module test_dpi_export_task_time;
  import "DPI-C" context task dpi_run_steps(input int n, input int step);
  export "DPI-C" task sv_step;

  task sv_step(input int i, input int d);
    #d $display("%0d: step %0d", $time, i);
  endtask

  initial begin
    dpi_run_steps(3, 4);
    $display("%0d: back in SystemVerilog", $time);
  end
endmodule
