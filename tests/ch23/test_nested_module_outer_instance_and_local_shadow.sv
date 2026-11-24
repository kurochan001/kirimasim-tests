/*
:name: test_nested_module_outer_instance_and_local_shadow
:description: A nested module uses its enclosing instance and a local declaration hides an outer name
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_module_outer_instance_and_local_shadow.expected
*/
// The child sees the input and parameter of the enclosing instance.
// It uses its own OFFSET even when the enclosing OFFSET is overridden.
module nested_reader #(parameter int SCALE = 1, OFFSET = 99)
                      (input int sample, output wire signed [31:0] answer);
  module reader(output wire signed [31:0] value);
    localparam int OFFSET = 3;
    assign value = sample * SCALE + OFFSET;
  endmodule

  reader child(answer);
endmodule

module test_nested_module_outer_instance_and_local_shadow;
  int sample;
  wire signed [31:0] first, second;
  nested_reader #(.SCALE(2), .OFFSET(10)) a(sample, first);
  nested_reader #(.SCALE(5), .OFFSET(20)) b(sample, second);

  initial begin
    sample = 4;
    #1 $display("first=%0d second=%0d", first, second);
    sample = -2;
    #1 $display("first=%0d second=%0d", first, second);
  end
endmodule
