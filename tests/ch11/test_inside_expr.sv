/*
:name: test_inside_expr
:description: Test inside expression (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_expr.expected
*/
// Test inside expression (IEEE 1800-2023 Section 11.4.13)

module test_inside_expr;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Value in set
    val = 5;
    if (val inside {1, 3, 5, 7, 9}) pass_count++;

    // Test 2: Value not in set
    val = 4;
    if (!(val inside {1, 3, 5, 7, 9})) pass_count++;

    // Test 3: Value in range
    val = 50;
    if (val inside {[40:60]}) pass_count++;

    $display("Inside expr tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Inside expr tests");
    end else begin
      $display("FAIL: Some inside expr tests failed");
    end
  end
endmodule
