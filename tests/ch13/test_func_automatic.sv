/*
:name: test_func_automatic
:description: Automatic functions test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_automatic.expected
*/
// Automatic functions test
module test_func_automatic;

  // Automatic function with local variables
  function automatic int compute_sum(int n);
    int sum;
    sum = 0;
    for (int i = 1; i <= n; i++) begin
      sum = sum + i;
    end
    return sum;
  endfunction

  // Automatic function for recursion
  function automatic int factorial(int n);
    int result;
    if (n <= 1)
      result = 1;
    else
      result = n * factorial(n - 1);
    return result;
  endfunction

  // Automatic function with multiple local vars
  function automatic int process_data(int a, int b, int c);
    int temp1, temp2, temp3;
    temp1 = a * 2;
    temp2 = b * 3;
    temp3 = c * 4;
    return temp1 + temp2 + temp3;
  endfunction

  // Automatic function called multiple times in same expression
  function automatic int double_it(int x);
    int local_val;
    local_val = x * 2;
    return local_val;
  endfunction

  // Automatic function with array local variable
  function automatic int array_sum(int size);
    int arr[10];
    int total;
    total = 0;
    for (int i = 0; i < size && i < 10; i++) begin
      arr[i] = i + 1;
      total = total + arr[i];
    end
    return total;
  endfunction

  initial begin
    int result, result2;
    int pass_count;

    pass_count = 0;

    // Test 1: Automatic function with loop
    result = compute_sum(10);
    if (result == 55) begin
      $display("Test 1 PASS: compute_sum(10) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: compute_sum(10) = %0d, expected 55", result);
    end

    // Test 2: Recursive automatic function
    result = factorial(6);
    if (result == 720) begin
      $display("Test 2 PASS: factorial(6) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: factorial(6) = %0d, expected 720", result);
    end

    // Test 3: Multiple local variables
    result = process_data(1, 2, 3);
    if (result == 20) begin  // 1*2 + 2*3 + 3*4 = 2 + 6 + 12 = 20
      $display("Test 3 PASS: process_data(1,2,3) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: process_data(1,2,3) = %0d, expected 20", result);
    end

    // Test 4: Multiple calls in same statement
    result = double_it(5) + double_it(10);
    if (result == 30) begin  // 10 + 20 = 30
      $display("Test 4 PASS: double_it(5) + double_it(10) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: result = %0d, expected 30", result);
    end

    // Test 5: Local array in automatic function
    result = array_sum(5);
    result2 = array_sum(3);
    if (result == 15 && result2 == 6) begin  // 1+2+3+4+5=15, 1+2+3=6
      $display("Test 5 PASS: array_sum(5)=%0d, array_sum(3)=%0d", result, result2);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: array_sum(5)=%0d (exp 15), array_sum(3)=%0d (exp 6)", result, result2);
    end

    if (pass_count == 5)
      $display("PASS: All automatic function tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
