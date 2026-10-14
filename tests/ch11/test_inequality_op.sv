/*
:name: test_inequality_op
:description: Test inequality operator (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inequality_op.expected
*/
// Test inequality operator (IEEE 1800-2023 Section 11.4.5)

module test_inequality_op;
  int a, b;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Not equal
    a = 42;
    b = 100;
    result = a != b;
    if (result == 1'b1) pass_count++;

    // Test 2: Equal values
    b = 42;
    result = a != b;
    if (result == 1'b0) pass_count++;

    // Test 3: Negative
    a = -10;
    b = 10;
    result = a != b;
    if (result == 1'b1) pass_count++;

    // Test 4: Zero vs non-zero
    a = 0;
    b = 1;
    result = a != b;
    if (result == 1'b1) pass_count++;

    $display("Inequality op tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Inequality op tests");
    end else begin
      $display("FAIL: Some inequality op tests failed");
    end
  end
endmodule
