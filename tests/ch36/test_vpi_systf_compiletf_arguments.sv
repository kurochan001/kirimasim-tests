/*
:name: test_vpi_systf_compiletf_arguments
:description: compiletf runs once for each call site, before the design is elaborated, and can read the arguments of the call as VPI objects, such as their width with vpi_get(vpiSize) (IEEE 1800-2023 Sections 36.8.2 and 38.6)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.8.2 36.8.3 36.4 38.6 38.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_compiletf_arguments.c
:expected_stdout: @test_vpi_systf_compiletf_arguments.expected
*/
// IEEE 1800-2023 §36.8.2: compiletf runs once for each call of a system
// function in the source, while the design is compiled, before calltf can
// run. §36.4, §38.23: the application reads the arguments of that call with
// vpi_iterate(vpiArgument) on the call handle, and §38.6: vpi_get(vpiSize)
// gives the width of each. The three calls of $vt_width have arguments of 4,
// 16 and 32 bits. §36.8.3: calltf runs at each of them.

module test_vpi_systf_compiletf_arguments;
  logic [3:0] n = 4'hf;
  logic [15:0] w = 16'h1234;
  int i = 5;

  initial begin
    $display("width of n: %0d", $vt_width(n));
    $display("width of w: %0d", $vt_width(w));
    $display("width of i: %0d", $vt_width(i));
    $vt_report;
  end
endmodule
