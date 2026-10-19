/*
:name: test_vpi_systf_task_arguments
:description: A system task registered with vpi_register_systf reads its arguments through vpi_iterate(vpiArgument) on the call handle (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9.1 36.5 38.37 38.18 38.23 38.40 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_task_arguments.c
:expected_stdout: @test_vpi_systf_task_arguments.expected
*/
// IEEE 1800-2023 §36.9.1, §38.37: a VPI application registers $vt_show from
// vlog_startup_routines. §36.4: the arguments of a user-defined system task are
// not passed to the C routine; it reads them with VPI. vpi_handle(vpiSysTfCall,
// NULL) returns the call (38.18), vpi_iterate(vpiArgument) and vpi_scan list
// its arguments in order (38.23, 38.40), and vpi_get_value reads each one in
// the format asked for (38.15). The last argument is an expression, whose size
// is that of b + 1 with an unsized constant, 32 bits.

module test_vpi_systf_task_arguments;
  reg [7:0] b;
  integer i;
  real r;

  initial begin
    b = 8'ha5;
    i = -7;
    r = 2.5;
    $vt_show(b, i, r, "text", b + 1);
  end
endmodule
