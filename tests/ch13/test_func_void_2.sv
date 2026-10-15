/*
:name: test_func_void_2
:description: Void functions test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_void_2.expected
*/
// Void functions test
module test_func_void_2;

  int global_counter;
  int global_array[4];
  string global_message;

  // Void function that modifies global variable
  function void increment_counter();
    global_counter++;
  endfunction

  // Void function with parameters
  function void set_counter(int value);
    global_counter = value;
  endfunction

  // Void function that modifies array
  function void init_array(int start_val);
    for (int i = 0; i < 4; i++) begin
      global_array[i] = start_val + i;
    end
  endfunction

  // Void function with output argument
  function void compute_both(int a, int b, output int sum_out, output int prod_out);
    sum_out = a + b;
    prod_out = a * b;
  endfunction

  // Void function that sets string
  function void set_message(string msg);
    global_message = msg;
  endfunction

  // Void function with conditional logic
  function void conditional_set(int value, bit use_double);
    if (use_double)
      global_counter = value * 2;
    else
      global_counter = value;
  endfunction

  initial begin
    int sum_result, prod_result;
    int pass_count;

    pass_count = 0;
    global_counter = 0;

    // Test 1: Simple void function
    increment_counter();
    increment_counter();
    increment_counter();
    if (global_counter == 3) begin
      $display("Test 1 PASS: increment_counter() called 3 times, counter = %0d", global_counter);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: counter = %0d, expected 3", global_counter);
    end

    // Test 2: Void function with parameter
    set_counter(100);
    if (global_counter == 100) begin
      $display("Test 2 PASS: set_counter(100), counter = %0d", global_counter);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: counter = %0d, expected 100", global_counter);
    end

    // Test 3: Void function modifying array
    init_array(10);
    if (global_array[0] == 10 && global_array[1] == 11 &&
        global_array[2] == 12 && global_array[3] == 13) begin
      $display("Test 3 PASS: init_array(10), array = [%0d,%0d,%0d,%0d]",
               global_array[0], global_array[1], global_array[2], global_array[3]);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: array initialization incorrect");
    end

    // Test 4: Void function with output arguments
    compute_both(7, 8, sum_result, prod_result);
    if (sum_result == 15 && prod_result == 56) begin
      $display("Test 4 PASS: compute_both(7,8) -> sum=%0d, prod=%0d", sum_result, prod_result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: sum=%0d (exp 15), prod=%0d (exp 56)", sum_result, prod_result);
    end

    // Test 5: Void function with conditional
    conditional_set(25, 1);
    if (global_counter == 50) begin
      $display("Test 5 PASS: conditional_set(25, 1), counter = %0d", global_counter);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: counter = %0d, expected 50", global_counter);
    end

    if (pass_count == 5)
      $display("PASS: All void function tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
