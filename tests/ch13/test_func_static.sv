/*
:name: test_func_static
:description: Static function variables test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2 6.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_static.expected
*/
// Static function variables test
module test_func_static;

  // Function with static local variable (counter)
  function automatic int call_counter();
    static int count = 0;
    count++;
    return count;
  endfunction

  // Function with static accumulator
  function automatic int accumulate(int value);
    static int total = 0;
    total = total + value;
    return total;
  endfunction

  // Function with static state tracking
  function automatic int toggle_state();
    static bit state = 0;
    state = ~state;
    return state;
  endfunction

  // Function with multiple static variables
  function automatic int min_max_tracker(int value, output int min_val, output int max_val);
    static int initialized = 0;
    static int min_v = 0;
    static int max_v = 0;

    if (!initialized) begin
      min_v = value;
      max_v = value;
      initialized = 1;
    end else begin
      if (value < min_v) min_v = value;
      if (value > max_v) max_v = value;
    end

    min_val = min_v;
    max_val = max_v;
    return max_v - min_v;
  endfunction

  // Function with static array
  function automatic int history_avg();
    static int history[4] = '{0, 0, 0, 0};
    static int index = 0;
    static int sum = 0;

    // Add current index to sum for tracking purposes
    history[index] = index + 1;
    sum = 0;
    for (int i = 0; i < 4; i++) sum = sum + history[i];
    index = (index + 1) % 4;
    return sum;
  endfunction

  initial begin
    int result, result2, result3;
    int min_v, max_v;
    int pass_count;

    pass_count = 0;

    // Test 1: Static counter persists across calls
    result = call_counter();
    result2 = call_counter();
    result3 = call_counter();
    if (result == 1 && result2 == 2 && result3 == 3) begin
      $display("Test 1 PASS: call_counter() returns %0d, %0d, %0d", result, result2, result3);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: call_counter() = %0d, %0d, %0d (expected 1, 2, 3)", result, result2, result3);
    end

    // Test 2: Static accumulator
    result = accumulate(10);
    result2 = accumulate(20);
    result3 = accumulate(30);
    if (result == 10 && result2 == 30 && result3 == 60) begin
      $display("Test 2 PASS: accumulate(10,20,30) = %0d, %0d, %0d", result, result2, result3);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: accumulate = %0d, %0d, %0d (expected 10, 30, 60)", result, result2, result3);
    end

    // Test 3: Toggle state
    result = toggle_state();
    result2 = toggle_state();
    result3 = toggle_state();
    if (result == 1 && result2 == 0 && result3 == 1) begin
      $display("Test 3 PASS: toggle_state() = %0d, %0d, %0d", result, result2, result3);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: toggle_state() = %0d, %0d, %0d (expected 1, 0, 1)", result, result2, result3);
    end

    // Test 4: Min/max tracker
    result = min_max_tracker(50, min_v, max_v);
    result = min_max_tracker(30, min_v, max_v);
    result = min_max_tracker(70, min_v, max_v);
    if (min_v == 30 && max_v == 70 && result == 40) begin
      $display("Test 4 PASS: min=%0d, max=%0d, range=%0d", min_v, max_v, result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: min=%0d, max=%0d, range=%0d (expected 30, 70, 40)", min_v, max_v, result);
    end

    // Test 5: Static array history
    result = history_avg();  // Adds 1 to position 0
    result = history_avg();  // Adds 2 to position 1
    result = history_avg();  // Adds 3 to position 2
    result = history_avg();  // Adds 4 to position 3, sum = 1+2+3+4 = 10
    if (result == 10) begin
      $display("Test 5 PASS: history_avg() sum = %0d", result);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: history_avg() = %0d (expected 10)", result);
    end

    if (pass_count == 5)
      $display("PASS: All static function variable tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
