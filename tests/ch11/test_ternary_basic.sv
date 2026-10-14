/*
:name: test_ternary_basic
:description: Test ternary conditional operator (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ternary_basic.expected
*/
// Test ternary conditional operator (IEEE 1800-2023 Section 11.4.11)

module test_ternary_basic;
  int a, b, result;
  int pass_count;

  initial begin
    pass_count = 0;
    a = 10;
    b = 20;

    // Test 1: True condition
    result = (a < b) ? 100 : 200;
    if (result == 100) pass_count++;

    // Test 2: False condition
    result = (a > b) ? 100 : 200;
    if (result == 200) pass_count++;

    // Test 3: Nested ternary
    result = (a == 10) ? ((b == 20) ? 1 : 2) : 3;
    if (result == 1) pass_count++;

    $display("Ternary tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Ternary tests");
    end else begin
      $display("FAIL: Some ternary tests failed");
    end
  end
endmodule
