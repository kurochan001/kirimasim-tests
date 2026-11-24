/*
:name: test_vpi_port_bit_excludes_name_and_port_index
:description: Port name and port index apply to the complete port but not to its bit handles
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.14 38.6 38.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_port_bit_excludes_name_and_port_index.expected
:vpi_c: @test_vpi_port_bit_excludes_name_and_port_index.c
*/
module port_source(input wire [7:4] vector_input, output wire flag);
  assign flag = vector_input[4];
endmodule
module test_vpi_port_bit_excludes_name_and_port_index;
  wire [7:4] stimulus = 4'b1001;
  wire observed;
  port_source child(stimulus, observed);
  initial #1 $finish;
endmodule
