/*
:name: test_func_default
:description: Default argument values test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_default.expected
*/
// Default argument values test
module test_func_default;

  // Function with single default argument
  function int increment(int value, int step = 1);
    return value + step;
  endfunction

  // Function with multiple default arguments
  function int compute(int a, int b = 10, int c = 100);
    return a + b + c;
  endfunction

  // Function with mixed default and non-default
  function int weighted_sum(int base, int multiplier, int offset = 0);
    return base * multiplier + offset;
  endfunction

  // Function with string default
  function string greet(string name, string prefix = "Hello");
    return {prefix, " ", name};
  endfunction

  // Function with expression as default
  parameter int DEFAULT_SIZE = 8;
  function int get_size(int size = DEFAULT_SIZE * 2);
    return size;
  endfunction

  initial begin
    int result;
    string msg;
    int pass_count;

    pass_count = 0;

    // Test 1: Using default value
    result = increment(5);
    if (result == 6) begin
      $display("Test 1 PASS: increment(5) = %0d (using default step=1)", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: increment(5) = %0d, expected 6", result);
    end

    // Test 2: Overriding default value
    result = increment(5, 3);
    if (result == 8) begin
      $display("Test 2 PASS: increment(5, 3) = %0d (overriding default)", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: increment(5, 3) = %0d, expected 8", result);
    end

    // Test 3: Multiple defaults - use all defaults
    result = compute(1);
    if (result == 111) begin
      $display("Test 3 PASS: compute(1) = %0d (using b=10, c=100)", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: compute(1) = %0d, expected 111", result);
    end

    // Test 4: Multiple defaults - override some
    result = compute(1, 20);
    if (result == 121) begin
      $display("Test 4 PASS: compute(1, 20) = %0d (overriding b, using c=100)", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: compute(1, 20) = %0d, expected 121", result);
    end

    // Test 5: Expression as default
    result = get_size();
    if (result == 16) begin
      $display("Test 5 PASS: get_size() = %0d (using default=DEFAULT_SIZE*2)", result);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: get_size() = %0d, expected 16", result);
    end

    if (pass_count == 5)
      $display("PASS: All default argument tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
