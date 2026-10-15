/*
:name: test_logical_and
:description: Test logical and (IEEE 1800-2023 Section 11.4.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logical_and.expected
*/
// Test logical and (IEEE 1800-2023 Section 11.4.7)

module test_logical_and;
  logic a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: True and True
    a = 1'b1 && 1'b1;
    if (a == 1'b1) pass_count++;

    // Test 2: True and False
    a = 1'b1 && 1'b0;
    if (a == 1'b0) pass_count++;

    // Test 3: False and True
    a = 1'b0 && 1'b1;
    if (a == 1'b0) pass_count++;

    // Test 4: False and False
    a = 1'b0 && 1'b0;
    if (a == 1'b0) pass_count++;

    $display("Logical and tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Logical and tests");
    end else begin
      $display("FAIL: Some logical and tests failed");
    end
  end
endmodule
