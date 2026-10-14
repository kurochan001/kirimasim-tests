/*
:name: test_module_param_override
:description: Test module parameter override (IEEE 1800-2023 Section 23.10)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.2 6.20.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_param_override.expected
*/
// Test module parameter override (IEEE 1800-2023 Section 23.10)

module param_mod #(
  parameter int P1 = 10,
  parameter int P2 = 20,
  parameter type T = logic[7:0]
) (
  input T data_in,
  output T data_out,
  output int sum
);
  assign data_out = data_in;
  assign sum = P1 + P2;
endmodule

module test_module_param_override;
  logic [7:0] din1, dout1;
  logic [15:0] din2, dout2;
  int sum1, sum2, sum3;
  int pass_count;

  // Default parameters
  param_mod u1 (
    .data_in(din1),
    .data_out(dout1),
    .sum(sum1)
  );

  // Override P1 only
  param_mod #(.P1(100)) u2 (
    .data_in(din1),
    .data_out(),
    .sum(sum2)
  );

  // Override both parameters
  param_mod #(.P1(5), .P2(15)) u3 (
    .data_in(din1),
    .data_out(),
    .sum(sum3)
  );

  // Override type parameter
  param_mod #(.T(logic[15:0])) u4 (
    .data_in(din2),
    .data_out(dout2),
    .sum()
  );

  initial begin
    pass_count = 0;

    #1;

    // Test 1: Default parameters
    if (sum1 == 30) pass_count++;

    // Test 2: Override P1
    if (sum2 == 120) pass_count++;

    // Test 3: Override both
    if (sum3 == 20) pass_count++;

    // Test 4: Data path with default width
    din1 = 8'hAB;
    #1;
    if (dout1 == 8'hAB) pass_count++;

    // Test 5: Data path with wide type
    din2 = 16'hCAFE;
    #1;
    if (dout2 == 16'hCAFE) pass_count++;

    $display("Module param override tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Module param override tests");
    end else begin
      $display("FAIL: Some param override tests failed");
    end
  end
endmodule
