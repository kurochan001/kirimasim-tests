/*
:name: test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array
:description: A matched interconnect vector is distributed across an array while a plain scalar is replicated
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.6 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array.expected
*/
module selected_buffer(input interconnect [1:0] data, input wire scalar,
                       output wire [1:0] selected, repeated);
  buf sliced_gate[1:0](selected, data);
  buf repeated_gate[1:0](repeated, scalar);
endmodule

module test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array;
  reg [1:0] stimulus = 2'b10;
  reg control = 1'b1;
  wire [1:0] selected, repeated;
  selected_buffer instance_under_test(stimulus, control, selected, repeated);
  initial begin
    #1 $display("first selected=%b repeated=%b", selected, repeated);
    stimulus = 2'b01;
    control = 1'b0;
    #1 $display("second selected=%b repeated=%b", selected, repeated);
  end
endmodule
