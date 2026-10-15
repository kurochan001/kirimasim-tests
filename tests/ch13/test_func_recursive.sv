/*
:name: test_func_recursive
:description: Recursive functions test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_recursive.expected
*/
// Recursive functions test
module test_func_recursive;

  // Simple factorial function
  function automatic int factorial(int n);
    if (n <= 1)
      return 1;
    else
      return n * factorial(n - 1);
  endfunction

  // Fibonacci function
  function automatic int fibonacci(int n);
    if (n <= 0)
      return 0;
    else if (n == 1)
      return 1;
    else
      return fibonacci(n - 1) + fibonacci(n - 2);
  endfunction

  // GCD using Euclidean algorithm
  function automatic int gcd(int a, int b);
    if (b == 0)
      return a;
    else
      return gcd(b, a % b);
  endfunction

  // Sum of digits
  function automatic int sum_digits(int n);
    if (n < 0)
      n = -n;
    if (n < 10)
      return n;
    else
      return (n % 10) + sum_digits(n / 10);
  endfunction

  // Power function (x^n)
  function automatic int power(int x, int n);
    if (n == 0)
      return 1;
    else if (n == 1)
      return x;
    else
      return x * power(x, n - 1);
  endfunction

  initial begin
    int result;
    int pass_count;

    pass_count = 0;

    // Test 1: Factorial
    result = factorial(5);
    if (result == 120) begin
      $display("Test 1 PASS: factorial(5) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: factorial(5) = %0d, expected 120", result);
    end

    // Test 2: Fibonacci
    result = fibonacci(10);
    if (result == 55) begin
      $display("Test 2 PASS: fibonacci(10) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: fibonacci(10) = %0d, expected 55", result);
    end

    // Test 3: GCD
    result = gcd(48, 18);
    if (result == 6) begin
      $display("Test 3 PASS: gcd(48, 18) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: gcd(48, 18) = %0d, expected 6", result);
    end

    // Test 4: Sum of digits
    result = sum_digits(12345);
    if (result == 15) begin
      $display("Test 4 PASS: sum_digits(12345) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: sum_digits(12345) = %0d, expected 15", result);
    end

    // Test 5: Power function
    result = power(2, 10);
    if (result == 1024) begin
      $display("Test 5 PASS: power(2, 10) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: power(2, 10) = %0d, expected 1024", result);
    end

    if (pass_count == 5)
      $display("PASS: All recursive function tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
