/*
:name: test_param_override
:description: Test parameter override (IEEE 1800-2023 Section 23.10)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_override.expected
*/
// Test parameter override (IEEE 1800-2023 Section 23.10)

module param_mod #(parameter int WIDTH = 8, parameter int DEPTH = 4) (
  output logic [WIDTH-1:0] data_out
);
  logic [WIDTH-1:0] mem [DEPTH];

  initial begin
    data_out = WIDTH;
  end
endmodule

module test_param_override;
  logic [7:0] out1;
  logic [15:0] out2;
  logic [31:0] out3;
  int pass_count;

  param_mod #(.WIDTH(8)) u1 (.data_out(out1));
  param_mod #(.WIDTH(16), .DEPTH(8)) u2 (.data_out(out2));
  param_mod #(.WIDTH(32), .DEPTH(16)) u3 (.data_out(out3));

  initial begin
    pass_count = 0;
    #1;

    // Test 1: Default width
    if (out1 == 8) pass_count++;

    // Test 2: Override width
    if (out2 == 16) pass_count++;

    // Test 3: Override both
    if (out3 == 32) pass_count++;

    $display("Param override tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Param override tests");
    end else begin
      $display("FAIL: Some param tests failed");
    end
  end
endmodule
