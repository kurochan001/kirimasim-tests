/*
:name: test_automatic_var
:description: Test automatic variables (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_automatic_var.expected
*/
// Test automatic variables (IEEE 1800-2023 Section 6.21)

module test_automatic_var;
  int pass_count;

  function automatic int factorial(int n);
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  endfunction

  function automatic int fibonacci(int n);
    if (n <= 1) return n;
    return fibonacci(n-1) + fibonacci(n-2);
  endfunction

  initial begin
    pass_count = 0;

    // Test 1: Factorial 5
    if (factorial(5) == 120) pass_count++;

    // Test 2: Factorial 3
    if (factorial(3) == 6) pass_count++;

    // Test 3: Fibonacci 6
    if (fibonacci(6) == 8) pass_count++;

    // Test 4: Fibonacci 10
    if (fibonacci(10) == 55) pass_count++;

    // Test 5: Base case factorial
    if (factorial(1) == 1) pass_count++;

    // Test 6: Base case fibonacci
    if (fibonacci(0) == 0) pass_count++;

    $display("Automatic var tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Automatic var tests");
    end else begin
      $display("FAIL: Some automatic tests failed");
    end
  end
endmodule
