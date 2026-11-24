/*
:name: test_vpi_put_value_rejects_gate_and_combinational_udp_instances
:description: A no-delay write rejects built-in gates and combinational UDP instances while accepting a variable
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 37.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stderr_regex: (?im)\A(?=[\s\S]*^gate write error: [^\n]*(?:gate|primitive|vpi_put_value))(?=[\s\S]*^udp write error: [^\n]*\bUDP\b)[\s\S]*\Z
:expected_stdout: @test_vpi_put_value_rejects_gate_and_combinational_udp_instances.expected
:vpi_c: @test_vpi_put_value_rejects_gate_and_combinational_udp_instances.c
*/
`timescale 1ns/1ns

primitive vpi_combinational_copy(q, input_value);
  output q;
  input input_value;
  table
    0 : 0;
    1 : 1;
    x : x;
  endtable
endprimitive

module test_vpi_put_value_rejects_gate_and_combinational_udp_instances;
  logic input_value = 0, control = 0;
  wire gate_output, udp_output;

  and builtin(gate_output, input_value, 1'b1);
  vpi_combinational_copy combinational(udp_output, input_value);

  initial begin
    #1 $vt_write_primitives;
    #1 $display("gate=%b udp=%b variable=%b", gate_output, udp_output, control);
  end
endmodule
