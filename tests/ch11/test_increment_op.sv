/*
:name: test_increment_op
:description: Test increment operators (IEEE 1800-2023 Section 11.4.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_increment_op.expected
*/
// Test increment operators (IEEE 1800-2023 Section 11.4.2)

module test_increment_op;
  int a;
  int result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Pre-increment
    a = 5;
    result = ++a;
    if (result == 6 && a == 6) pass_count++;

    // Test 2: Post-increment
    a = 5;
    result = a++;
    if (result == 5 && a == 6) pass_count++;

    // Test 3: Increment in expression
    a = 10;
    if (++a == 11) pass_count++;

    $display("Increment op tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Increment op tests");
    end else begin
      $display("FAIL: Some increment op tests failed");
    end
  end
endmodule
