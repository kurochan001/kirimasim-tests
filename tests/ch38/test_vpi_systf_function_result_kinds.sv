/*
:name: test_vpi_systf_function_result_kinds
:description: The five sysfunctype values give user-defined system functions an int, real, time, sized or sized signed result; sizetf is called only for the two sized kinds, which return 32 bits when they have no sizetf, and sysfunctype is ignored for a system task (IEEE 1800-2023 Section 38.37.1, 36.8.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37.1 36.8.1 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_function_result_kinds.c
:expected_stdout: @test_vpi_systf_function_result_kinds.expected
*/
// IEEE 1800-2023 §38.37.1: the sysfunctype of a system function is one of
// vpiIntFunc, vpiRealFunc, vpiTimeFunc, vpiSizedFunc and vpiSizedSignedFunc,
// and it is used only when type is vpiSysFunc. sizetf is called only for a
// vpiSysFunc whose sysfunctype is vpiSizedFunc or vpiSizedSignedFunc; such a
// function without sizetf returns 32 bits. §36.8.1: sizetf is called at most
// once, and gives the width of the result. §38.34: calltf sets the result
// with vpi_put_value on the call handle.
//
// Every routine is registered with a sizetf that counts its calls and returns
// 40, except $vt_sized32 and $vt_signed32, which have none. $vt_int puts -5,
// which an int result sign-extends to 64 bits; $vt_real puts 2.5; $vt_time
// puts the time 256 * 2**32 + 3; $vt_sized40 and $vt_signed40 put 40 bits with
// only bit 39 set, which a signed result sign-extends; $vt_sized32 and
// $vt_signed32 put 64 bits with bits 63 and 31 set, of which a 32-bit result
// keeps bit 31. $vt_task is a system task registered with sysfunctype
// vpiRealFunc, which is ignored: it runs as a task. $vt_report prints how
// often each sizetf ran.
//
// Icarus Verilog 13.0 needs the types of user-defined system functions when it
// compiles and stops at the first real result, and Verilator 5.052 cannot call
// user-defined system tasks and functions, so :oracle: names no simulator.

module test_vpi_systf_function_result_kinds;
  logic [63:0] i, s40, g40, s32, g32;
  real r;
  time t;

  initial begin
    i = $vt_int;
    r = $vt_real;
    t = $vt_time;
    s40 = $vt_sized40;
    g40 = $vt_signed40;
    s32 = $vt_sized32;
    g32 = $vt_signed32;
    $vt_task;
    $display("int: %h", i);
    $display("real: %0.2f", r);
    $display("time: %0d", t);
    $display("sized 40: %h, sized signed 40: %h", s40, g40);
    $display("sized without sizetf: %h, sized signed without sizetf: %h", s32, g32);
    $vt_report;
  end
endmodule
