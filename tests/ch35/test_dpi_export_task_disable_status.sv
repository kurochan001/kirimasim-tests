/*
:name: test_dpi_export_task_disable_status
:description: An exported task returns exactly 1 to C, and svIsDisabledState gives 1, when it returns because a block above the import is disabled, while an exported task that disables itself returns 0 and leaves its parent import out of the disabled state (IEEE 1800-2023 Section 35.9)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9 35.8 35.5.3 9.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_task_disable_status.c
:expected_stdout: @test_dpi_export_task_disable_status.expected
*/
// IEEE 1800-2023 §35.9: an imported subroutine is in the disabled state when
// a disable targets it or a parent of it; the simulator makes an exported
// task return 1 when it returns because of a disable and 0 otherwise, and
// svIsDisabledState tells the import whether it is disabled; a disabled
// imported task acknowledges by returning 1. When the exported task itself
// is the target of the disable, its parent import is not in the disabled
// state: the exported task returns 0 and svIsDisabledState gives 0. At 1 the
// block worker calls the context task dpi_run_a, whose exported task
// sv_stop_worker disables worker (9.6.2), so the statement after the import
// does not run. At 2 dpi_run_b calls sv_self, which disables itself, so the
// rest of sv_self does not run, but the import goes on and returns normally.
// The C code keeps the return values of the exported tasks and the results
// of svIsDisabledState, which are printed at 3. Icarus Verilog 13.0 has no
// DPI, and Verilator 5.052 rejects the disable in an exported task as an
// unsupported timing control.

`timescale 1ns/1ns

module test_dpi_export_task_disable_status;
  import "DPI-C" context task dpi_run_a();
  import "DPI-C" context task dpi_run_b();
  import "DPI-C" function void dpi_report(output int ar, output int as, output int br,
                                          output int bs);
  export "DPI-C" task sv_stop_worker;
  export "DPI-C" task sv_self;

  task sv_stop_worker();
    disable worker;
  endtask

  task sv_self();
    disable sv_self;
    $display("%0t: sv_self goes on after disabling itself", $time);
  endtask

  initial begin : worker
    #1 dpi_run_a();
    $display("%0t: worker goes on after the disabled import", $time);
  end

  initial begin
    int ar, as, br, bs;
    #2 dpi_run_b();
    $display("%0t: the import of sv_self returned normally", $time);
    #1 dpi_report(ar, as, br, bs);
    $display("parent block disabled: exported task returned %0d, svIsDisabledState %0d", ar, as);
    $display("exported task disabled itself: returned %0d, svIsDisabledState %0d", br, bs);
  end
endmodule
