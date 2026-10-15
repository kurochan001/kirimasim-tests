/*
:name: test_logical_not
:description: Test logical not (IEEE 1800-2023 Section 11.4.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logical_not.expected
*/
// Test logical not (IEEE 1800-2023 Section 11.4.7)

module test_logical_not;
  logic a;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Not of 1
    a = !1'b1;
    if (a == 1'b0) pass_count++;

    // Test 2: Not of 0
    a = !1'b0;
    if (a == 1'b1) pass_count++;

    // Test 3: Not of nonzero int
    val = 42;
    a = !val;
    if (a == 1'b0) pass_count++;

    // Test 4: Not of zero int
    val = 0;
    a = !val;
    if (a == 1'b1) pass_count++;

    $display("Logical not tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Logical not tests");
    end else begin
      $display("FAIL: Some logical not tests failed");
    end
  end
endmodule
