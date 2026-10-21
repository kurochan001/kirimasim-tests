/*
:name: test_vpi_systf_function_in_continuous_assign
:description: A user-defined system function can be called in a continuous assignment, which calls it again when its argument changes (IEEE 1800-2023 Section 36.5)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.5 10.3 13.4 38.37.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_function_in_continuous_assign.c
:expected_stdout: @test_vpi_systf_function_in_continuous_assign.expected
*/
// IEEE 1800-2023 §36.5: a user-defined system function can be used in the same
// places as a SystemVerilog function (13.4), which includes the right-hand
// side of a continuous assignment. $vt_twice, registered as a vpiIntFunc
// (38.37.1), returns twice its argument. §10.3: the assignment is evaluated
// again whenever an operand of its expression changes, here the argument a.
// The Icarus Verilog runner loads the application only when the design runs,
// and Icarus Verilog 13.0 needs the system function when it compiles a
// continuous assignment, so the test does not compile there.

`timescale 1ns/1ns

module test_vpi_systf_function_in_continuous_assign;
  int a = 3;
  wire [31:0] w;

  assign w = $vt_twice(a) + 1;

  initial begin
    #1 $display("a=%0d w=%0d", a, w);
    a = 5;
    #1 $display("a=%0d w=%0d", a, w);
  end
endmodule
