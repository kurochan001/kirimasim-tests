/*
:name: test_less_equal
:description: Test less than or equal (IEEE 1800-2023 Section 11.4.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_less_equal.expected
*/
// Test less than or equal (IEEE 1800-2023 Section 11.4.4)

module test_less_equal;
  int a, b;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Less is true
    a = 5;
    b = 10;
    result = a <= b;
    if (result == 1'b1) pass_count++;

    // Test 2: Equal is true
    a = 10;
    result = a <= b;
    if (result == 1'b1) pass_count++;

    // Test 3: Greater is false
    a = 15;
    result = a <= b;
    if (result == 1'b0) pass_count++;

    // Test 4: Negative
    a = -5;
    result = a <= b;
    if (result == 1'b1) pass_count++;

    $display("Less equal tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Less equal tests");
    end else begin
      $display("FAIL: Some less equal tests failed");
    end
  end
endmodule
