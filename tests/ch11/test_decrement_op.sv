/*
:name: test_decrement_op
:description: Test decrement operators (IEEE 1800-2023 Section 11.4.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_decrement_op.expected
*/
// Test decrement operators (IEEE 1800-2023 Section 11.4.2)

module test_decrement_op;
  int a;
  int result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Pre-decrement
    a = 10;
    result = --a;
    if (result == 9 && a == 9) pass_count++;

    // Test 2: Post-decrement
    a = 10;
    result = a--;
    if (result == 10 && a == 9) pass_count++;

    // Test 3: Decrement in expression
    a = 5;
    if (--a == 4) pass_count++;

    $display("Decrement op tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Decrement op tests");
    end else begin
      $display("FAIL: Some decrement op tests failed");
    end
  end
endmodule
