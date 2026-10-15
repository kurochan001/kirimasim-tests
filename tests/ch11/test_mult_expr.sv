/*
:name: test_mult_expr
:description: Test multiplication expressions (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mult_expr.expected
*/
// Test multiplication expressions (IEEE 1800-2023 Section 11.4.3)

module test_mult_expr;
  logic [15:0] result;
  logic [7:0] a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple multiply
    a = 8'd5;
    b = 8'd3;
    result = a * b;
    if (result == 16'd15) pass_count++;

    // Test 2: Zero multiply
    a = 8'd100;
    b = 8'd0;
    result = a * b;
    if (result == 16'd0) pass_count++;

    // Test 3: One multiply
    a = 8'd42;
    b = 8'd1;
    result = a * b;
    if (result == 16'd42) pass_count++;

    // Test 4: Larger values
    a = 8'd10;
    b = 8'd20;
    result = a * b;
    if (result == 16'd200) pass_count++;

    // Test 5: Max values
    a = 8'd255;
    b = 8'd255;
    result = a * b;
    if (result == 16'd65025) pass_count++;

    // Test 6: Power of 2
    a = 8'd8;
    b = 8'd8;
    result = a * b;
    if (result == 16'd64) pass_count++;

    $display("Mult expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Mult expr tests");
    end else begin
      $display("FAIL: Some mult tests failed");
    end
  end
endmodule
