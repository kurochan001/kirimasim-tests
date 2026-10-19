/*
:name: test_vpi_systf_function_types
:description: User-defined system functions return a sized unsigned or signed value whose width sizetf gives, a real value, or a 32-bit integer, put by calltf with vpi_put_value (IEEE 1800-2023 Section 36.8.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.8.1 36.5 36.8.3 38.37.1 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_function_types.c
:expected_stdout: @test_vpi_systf_function_types.expected
*/
// IEEE 1800-2023 §36.8.1, §38.37.1: a system function of sysfunctype
// vpiSizedFunc or vpiSizedSignedFunc returns as many bits as its sizetf routine
// says, here 8; vpiRealFunc returns a real and vpiIntFunc an integer. §38.34:
// calltf sets the result with vpi_put_value on the call handle. §36.8.3: calltf
// runs at every call, so $vt_count counts. 200 + 100 = 300 is 44 in 8 bits; 100
// + 100 = 200 is -56 as a signed 8-bit value, which is sign-extended when
// assigned to 16 bits. Icarus Verilog 13.0 needs the return types of
// user-defined system functions when it compiles (in a .sft file) and stops at
// the first real result, and Verilator 5.052 does not support user-defined
// system functions.

module test_vpi_systf_function_types;
  integer s, t, k;
  real h;
  reg [15:0] w;

  initial begin
    s = $vt_sum8(200, 100);
    t = $vt_sum8s(100, 100);
    w = $vt_sum8s(100, 100);
    h = $vt_half(5);
    $display("sum8: %0d", s);
    $display("sum8s: %0d, in 16 bits: %h", t, w);
    $display("half: %0.2f", h);
    for (k = 0; k < 3; k = k + 1)
      $display("count: %0d", $vt_count);
  end
endmodule
