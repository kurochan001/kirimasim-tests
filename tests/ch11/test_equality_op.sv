/*
:name: test_equality_op
:description: Test equality operator (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_equality_op.expected
*/
// Test equality operator (IEEE 1800-2023 Section 11.4.5)

module test_equality_op;
  int a, b;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Equal values
    a = 42;
    b = 42;
    result = a == b;
    if (result == 1'b1) pass_count++;

    // Test 2: Not equal values
    b = 100;
    result = a == b;
    if (result == 1'b0) pass_count++;

    // Test 3: Zero
    a = 0;
    b = 0;
    result = a == b;
    if (result == 1'b1) pass_count++;

    // Test 4: Negative
    a = -10;
    b = -10;
    result = a == b;
    if (result == 1'b1) pass_count++;

    $display("Equality op tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Equality op tests");
    end else begin
      $display("FAIL: Some equality op tests failed");
    end
  end
endmodule
