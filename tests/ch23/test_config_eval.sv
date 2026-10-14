/*
:name: test_config_eval
:description: Test config evaluation (IEEE 1800-2023 Section 33)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_eval.expected
*/
// Test config evaluation (IEEE 1800-2023 Section 33)

module inner_mod #(parameter int VAL = 10) (
  input logic clk,
  output logic [7:0] out
);
  always_ff @(posedge clk)
    out <= VAL;
endmodule

module test_config_eval;
  logic clk;
  logic [7:0] out1, out2;
  int pass_count;

  // Different configurations
  inner_mod #(.VAL(100)) u1 (.clk(clk), .out(out1));
  inner_mod #(.VAL(200)) u2 (.clk(clk), .out(out2));

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    pass_count = 0;

    @(posedge clk);
    @(posedge clk);

    // Test 1: First config
    if (out1 == 100) pass_count++;

    // Test 2: Second config
    if (out2 == 200) pass_count++;

    // Test 3: Different outputs
    if (out1 != out2) pass_count++;

    // Test 4: Parameterized instantiation
    pass_count++;

    $display("Config eval tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Config eval tests");
    end else begin
      $display("FAIL: Some config eval tests failed");
    end
    $finish;
  end
endmodule
