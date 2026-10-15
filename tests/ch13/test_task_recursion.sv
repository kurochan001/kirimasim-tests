/*
:name: test_task_recursion
:description: Recursive task/function edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4.2 13.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_recursion.expected
*/
// IEEE 1800-2023 §13.3: Recursive task/function edge cases
`timescale 1ns/1ps

module test_task_recursion;

  // Recursive function: factorial
  function automatic int factorial(int n);
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  endfunction

  // Recursive function: fibonacci
  function automatic int fibonacci(int n);
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return fibonacci(n - 1) + fibonacci(n - 2);
  endfunction

  // Mutual recursion: even/odd check
  function automatic bit is_even(int n);
    if (n == 0) return 1;
    return is_odd(n - 1);
  endfunction

  function automatic bit is_odd(int n);
    if (n == 0) return 0;
    return is_even(n - 1);
  endfunction

  // Tail recursion pattern
  function automatic int sum_tail(int n, int acc = 0);
    if (n <= 0) return acc;
    return sum_tail(n - 1, acc + n);
  endfunction

  // Deep recursion stress test
  function automatic int deep_recursion(int depth);
    if (depth <= 0) return 0;
    return 1 + deep_recursion(depth - 1);
  endfunction

  int result;

  initial begin
    // Test 1: Factorial
    result = factorial(5);
    if (result != 120) begin
      $display("FAIL: factorial(5) expected 120, got %0d", result);
      $finish;
    end

    // Test 2: Fibonacci
    result = fibonacci(10);
    if (result != 55) begin
      $display("FAIL: fibonacci(10) expected 55, got %0d", result);
      $finish;
    end

    // Test 3: Mutual recursion - even
    if (!is_even(10)) begin
      $display("FAIL: is_even(10) should be true");
      $finish;
    end

    // Test 4: Mutual recursion - odd
    if (!is_odd(7)) begin
      $display("FAIL: is_odd(7) should be true");
      $finish;
    end

    // Test 5: Tail recursion
    result = sum_tail(10);
    if (result != 55) begin
      $display("FAIL: sum_tail(10) expected 55, got %0d", result);
      $finish;
    end

    // Test 6: Deep recursion (moderate depth)
    result = deep_recursion(100);
    if (result != 100) begin
      $display("FAIL: deep_recursion(100) expected 100, got %0d", result);
      $finish;
    end

    $display("PASS: Recursive task/function edge cases");
    $finish;
  end
endmodule
