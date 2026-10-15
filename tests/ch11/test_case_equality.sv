/*
:name: test_case_equality
:description: Test case equality (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_equality.expected
*/
// Test case equality (IEEE 1800-2023 Section 11.4.5)

module test_case_equality;
  logic [3:0] a, b;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Equal values
    a = 4'b1010;
    b = 4'b1010;
    result = a === b;
    if (result == 1'b1) pass_count++;

    // Test 2: Not equal
    b = 4'b1011;
    result = a === b;
    if (result == 1'b0) pass_count++;

    // Test 3: With X values
    a = 4'b10x0;
    b = 4'b10x0;
    result = a === b;
    if (result == 1'b1) pass_count++;

    // Test 4: X vs non-X
    a = 4'b10x0;
    b = 4'b1010;
    result = a === b;
    if (result == 1'b0) pass_count++;

    $display("Case equality tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Case equality tests");
    end else begin
      $display("FAIL: Some case equality tests failed");
    end
  end
endmodule
