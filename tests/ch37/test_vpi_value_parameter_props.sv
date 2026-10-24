/*
:name: test_vpi_value_parameter_props
:description: Value parameters of an instance and of a generate block in it are iterated by vpiParameter from their scope and give their module, their scope and their full name, vpiSigned and vpiSize of their type, and their value at the end of elaboration (IEEE 1800-2023 Section 37.28)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.28 6.20.2 23.10 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_value_parameter_props.c
:expected_stdout: @test_vpi_value_parameter_props.expected
*/
// IEEE 1800-2023 §37.28: the parameters group (value parameters here) has
// one-to-one relations to the module and to the scope that declare a
// parameter, and the scope relation vpiParameter; parameters have vpiFullName,
// and value parameters vpiSigned, vpiSize and a value. The submodule declares
// W (int), S (signed [7:0]), B (bit [3:0]) and U (no type or range), and its
// generate block g the local parameter GL (27.5). vpi_iterate(vpiParameter, g)
// gives GL only, and that of the instance u its four parameters. vpiModule of
// every parameter, GL included, is u; vpiScope is u for W and g for GL.
// Detail 1: the value is the one at the end of elaboration: W is overridden
// to 9 (23.10), so GL = W + 1 is 10, while B, S and U keep their defaults.
// vpiSigned is 1 for int and signed [7:0], 0 for bit [3:0]; vpiSize is 32, 8
// and 4 (the size of U, from an unsized literal, is not printed: 5.7.1 leaves
// it to the tool beyond 32 bits). Parameters are listed sorted by name.

module test_vpi_value_parameter_props_sub #(parameter int W = 4, parameter signed [7:0] S = -3,
                                            parameter bit [3:0] B = 4'd5, parameter U = 5) ();
  if (W > 0) begin : g
    localparam int GL = W + 1;
  end
endmodule

module test_vpi_value_parameter_props;
  test_vpi_value_parameter_props_sub #(.W(9)) u();

  initial #1 $vt_params;
endmodule
