/*
:name: test_vpi_sys_func_call_value_info
:description: an application reaches the system function call that invoked it with vpi_handle(vpiSysTfCall, NULL), sets its value with vpi_put_value and reads it back with vpi_get_value; vpiUserDefn tells a user-defined system function call, whose systf object gives its registration through vpi_get_systf_info, from a built-in one, vpiFuncType gives the result type of a system function call, and an omitted argument is a vpiNullOp operation while null is a vpiNullConst constant (IEEE 1800-2023 Section 37.42)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.42 38.12 38.15 38.34 36.4 20.3 21.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_sys_func_call_value_info.c
:expected_stdout: @test_vpi_sys_func_call_value_info.expected
*/
// IEEE 1800-2023 §37.42: the system task or function call that invoked an
// application is vpi_handle(vpiSysTfCall, NULL) (detail 3); for the call
// $vt_val(3) it is that call, whose argument is 3, and not the call $vt_val(5)
// written as an argument of $vt_args. vpi_put_value sets the value of a system
// function call and vpi_get_value returns its current value (detail 4,
// 38.34, 38.15): the calltf puts ten times its argument, 30, reads it back,
// and r gets 30. When vpiUserDefn of a call is TRUE, the systf object
// (vpiUserSystf) gives the registered properties through vpi_get_systf_info
// (detail 5, 38.12): the name $vt_val, the type vpiSysFunc and the function
// type vpiIntFunc; it is FALSE for the built-in $time and $realtime.
// vpiFuncType of a system function call is its result type: vpiTimeFunc for
// $time, vpiRealFunc for $realtime (20.3) and vpiIntFunc for $vt_val. An
// omitted argument (21.2.1) is an operation with vpiOpType vpiNullOp, null a
// constant with vpiConstType vpiNullConst, and the empty string "" a string
// constant (detail 8). Arguments are not evaluated when $vt_args is called
// (36.4).

`timescale 1ns/1ns

module test_vpi_sys_func_call_value_info;
  int r;

  initial begin
    #1 r = $vt_val(3);
    $display("r = %0d", r);
    $vt_args($time, $realtime, $vt_val(5), , null, "");
  end
endmodule
