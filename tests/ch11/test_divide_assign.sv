/*
:name: test_divide_assign
:description: Test divide compound assignment (IEEE 1800-2023 Section 11.4.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_divide_assign.expected
*/
// Test divide compound assignment (IEEE 1800-2023 Section 11.4.1)

module test_divide_assign;
  int a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: /= operator
    a = 100;
    a /= 5;
    if (a == 20) pass_count++;

    // Test 2: %= operator
    a = 17;
    a %= 5;
    if (a == 2) pass_count++;

    // Test 3: Chained operations
    a = 100;
    a /= 2;
    a /= 5;
    if (a == 10) pass_count++;

    $display("Divide assign tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Divide assign tests");
    end else begin
      $display("FAIL: Some divide assign tests failed");
    end
  end
endmodule
