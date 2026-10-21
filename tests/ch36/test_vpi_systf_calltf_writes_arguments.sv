/*
:name: test_vpi_systf_calltf_writes_arguments
:description: calltf runs at every call of a user-defined system task and can write the variables passed as arguments with vpi_put_value (IEEE 1800-2023 Sections 36.8.3, 38.34 and 38.15)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.8.3 36.4 38.34 38.15 38.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_calltf_writes_arguments.c
:expected_stdout: @test_vpi_systf_calltf_writes_arguments.expected
*/
// IEEE 1800-2023 §36.8.3: calltf runs each time the call executes, with the
// call handle of that execution. §36.4, §38.23: the application reads the
// arguments through vpi_iterate(vpiArgument). §38.15: vpi_get_value reads the
// value of the target and of the amount, and §38.34: vpi_put_value with
// vpiNoDelay writes the sum to the variable passed as the first argument.
// $vt_add runs twice on a and once on b, and $vt_set writes c whole.

module test_vpi_systf_calltf_writes_arguments;
  int a = 1, b = 10;
  logic [7:0] c = 8'hf0;

  initial begin
    $vt_add(a, 5);
    $vt_add(b, -3);
    $vt_set(c, 8'h3c);
    $display("a=%0d b=%0d c=%h", a, b, c);
    $vt_add(a, 100);
    $display("a=%0d", a);
  end
endmodule
