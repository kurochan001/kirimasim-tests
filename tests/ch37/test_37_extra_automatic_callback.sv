/*
:name: test_37_extra_automatic_callback
:description: A value-change callback cannot be placed on an automatic variable, while the same callback on a static variable is accepted and fires, and no callback fires for the automatic variable (IEEE 1800-2023 Section 37.43)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 38.36 38.36.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_37_extra_automatic_callback.c
:expected_stdout: @test_37_extra_automatic_callback.expected
*/
// IEEE 1800-2023 §37.43 detail 2: it shall be illegal to place value change
// callbacks on automatic variables. The task bump is automatic and declares
// the automatic variable auto_v; the module declares the static variable
// stat. While bump runs, the application registers cbValueChange on both
// variables. The standard makes the first call illegal; the application
// records that the implementation rejects it with a NULL handle, while the
// registration on the static variable returns a callback handle. bump then
// changes auto_v, which produces no callback, and later changes stat, which
// produces one callback with the new value. The counts show that only the
// static variable was watched.

module test_37_extra_automatic_callback;
  int stat;

  task automatic bump;
    int auto_v;

    stat = 0;
    auto_v = 1;
    $vt_watch;
    auto_v = 2;
    stat = 5;
    #1 $vt_report;
  endtask

  initial bump;
endmodule
