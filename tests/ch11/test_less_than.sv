/*
:name: test_less_than
:description: Test less than operator (IEEE 1800-2023 Section 11.4.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_less_than.expected
*/
// Test less than operator (IEEE 1800-2023 Section 11.4.4)

module test_less_than;
  int a, b;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Less is true
    a = 5;
    b = 10;
    result = a < b;
    if (result == 1'b1) pass_count++;

    // Test 2: Less is false
    result = b < a;
    if (result == 1'b0) pass_count++;

    // Test 3: Equal values
    a = 10;
    result = a < b;
    if (result == 1'b0) pass_count++;

    // Test 4: Negative values
    a = -5;
    b = 5;
    result = a < b;
    if (result == 1'b1) pass_count++;

    $display("Less than tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Less than tests");
    end else begin
      $display("FAIL: Some less than tests failed");
    end
  end
endmodule
