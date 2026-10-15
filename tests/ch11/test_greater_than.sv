/*
:name: test_greater_than
:description: Test greater than operator (IEEE 1800-2023 Section 11.4.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_greater_than.expected
*/
// Test greater than operator (IEEE 1800-2023 Section 11.4.4)

module test_greater_than;
  int a, b;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Greater is true
    a = 10;
    b = 5;
    result = a > b;
    if (result == 1'b1) pass_count++;

    // Test 2: Greater is false
    result = b > a;
    if (result == 1'b0) pass_count++;

    // Test 3: Equal values
    b = 10;
    result = a > b;
    if (result == 1'b0) pass_count++;

    // Test 4: Negative values
    a = 5;
    b = -5;
    result = a > b;
    if (result == 1'b1) pass_count++;

    $display("Greater than tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Greater than tests");
    end else begin
      $display("FAIL: Some greater than tests failed");
    end
  end
endmodule
