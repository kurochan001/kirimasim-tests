/*
:name: test_net_ports_used_in_the_reverse_direction
:description: Use input and output nets in the reverse direction and observe whether each connection propagates backwards
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:top_module: test_net_ports_used_in_the_reverse_direction
:expected_exit: 0
:expected_stdout: @test_net_ports_used_in_the_reverse_direction.expected
*/
module input_direction(input wire input_backward);
  assign input_backward = 1'b1;
endmodule

module output_direction(output wire output_backward, output wire inside_value);
  assign inside_value = output_backward;
endmodule

module test_net_ports_used_in_the_reverse_direction;
  wire outward;
  wire inward = 1'b1;
  wire inside_value;
  input_direction use_input_as_output(.input_backward(outward));
  output_direction use_output_as_input(.output_backward(inward), .inside_value(inside_value));

  initial begin
    #1;
    if ($test$plusargs("report_directions"))
      $display("input outward=%b output inward=%b", outward, inside_value);
    if ((outward === 1'b1 || outward === 1'bz) &&
        (inside_value === 1'b1 || inside_value === 1'bz))
      $display("both nets had a permitted value");
  end
endmodule
