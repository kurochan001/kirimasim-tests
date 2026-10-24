/*
:name: test_vpi_sizetf_exclusions_default_width
:description: sizetf is not called for a user-defined system task or for a system function of sysfunctype vpiRealFunc, a sized system function returns as many bits as its sizetf gives, and one without a sizetf returns 32 bits (IEEE 1800-2023 Section 36.8.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.8.1 38.37.1 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_sizetf_exclusions_default_width.c
:expected_stdout: @test_vpi_sizetf_exclusions_default_width.expected
*/
// IEEE 1800-2023 §36.8.1: the value that sizetf returns is the number of bits
// that calltf provides as the result of the system function; without a
// sizetf a user-defined system function returns 32 bits; sizetf is not called
// for user-defined system tasks or for functions whose sysfunctype is
// vpiRealFunc. The application registers the task $vt_task and the real
// function $vt_real, each with a sizetf that counts its calls, the sized
// function $vt_wide with a sizetf that gives 40, and the sized function
// $vt_nosize without a sizetf. calltf of both sized functions puts the 40-bit
// value 40'h12_3456_789a (38.34), which keeps its 40 bits for $vt_wide and is
// cut to its 32 low bits for $vt_nosize when it is assigned to a 64-bit
// variable; $vt_real returns 2.5. $vt_report prints the sizetf calls.
// Icarus Verilog 13.0 needs the types of user-defined system functions when
// it compiles (in a .sft file) and stops at the real result, and Verilator
// 5.052 does not support calls of user-defined system tasks.

module test_vpi_sizetf_exclusions_default_width;
  logic [63:0] w, n;
  real r;

  initial begin
    $vt_task;
    r = $vt_real;
    w = $vt_wide;
    n = $vt_nosize;
    $display("$vt_real: %0.1f", r);
    $display("$vt_wide: %h", w);
    $display("$vt_nosize: %h", n);
    $vt_report;
  end
endmodule
