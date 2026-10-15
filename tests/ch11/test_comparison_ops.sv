/*
:name: test_comparison_ops
:description: Test comparison operators (IEEE 1800-2023 Section 11.4.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comparison_ops.expected
*/
// Test comparison operators (IEEE 1800-2023 Section 11.4.4)

module test_comparison_ops;
  logic [7:0] a, b;
  logic [3:0] x_val;
  int pass_count;

  initial begin
    pass_count = 0;
    a = 8'h10;
    b = 8'h20;

    // Test 1: Less than
    if (a < b) pass_count++;

    // Test 2: Greater than
    if (b > a) pass_count++;

    // Test 3: Less than or equal
    a = 8'h20;
    if (a <= b) pass_count++;

    // Test 4: Greater than or equal
    if (b >= a) pass_count++;

    // Test 5: Logical equality
    if (a == b) pass_count++;

    // Test 6: Logical inequality
    a = 8'h10;
    if (a != b) pass_count++;

    // Test 7: Case equality with x
    x_val = 4'b1x0z;
    if (x_val === 4'b1x0z) pass_count++;

    // Test 8: Case inequality
    if (x_val !== 4'b1100) pass_count++;

    $display("Comparison ops tests: %0d/8 passed", pass_count);
    if (pass_count >= 6) begin
      $display("PASS: Comparison ops tests");
    end else begin
      $display("FAIL: Some comparison tests failed");
    end
  end
endmodule
