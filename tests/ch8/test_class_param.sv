/*
:name: test_class_param
:description: Test: Parameterized class
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_param.expected
*/
// Test: Parameterized class
// IEEE 1800-2023 Section 8.25 - Parameterized classes

module test_class_param;

  // Parameterized class with value parameter
  class Stack #(int DEPTH = 8);
    int data[DEPTH];
    int top;

    function new();
      top = 0;
    endfunction

    function bit push(int val);
      if (top < DEPTH) begin
        data[top] = val;
        top++;
        return 1;
      end
      return 0;
    endfunction

    function int pop();
      if (top > 0) begin
        top--;
        return data[top];
      end
      return -1;
    endfunction

    function bit is_empty();
      return (top == 0);
    endfunction

    function bit is_full();
      return (top == DEPTH);
    endfunction

    function int size();
      return top;
    endfunction

    function int capacity();
      return DEPTH;
    endfunction
  endclass

  // Parameterized class with multiple parameters
  class Matrix #(int ROWS = 2, int COLS = 2);
    int data[ROWS][COLS];

    function new();
      foreach (data[i,j])
        data[i][j] = 0;
    endfunction

    function void set(int r, int c, int val);
      if (r < ROWS && c < COLS)
        data[r][c] = val;
    endfunction

    function int get(int r, int c);
      if (r < ROWS && c < COLS)
        return data[r][c];
      return 0;
    endfunction

    function int rows();
      return ROWS;
    endfunction

    function int cols();
      return COLS;
    endfunction

    function int total_cells();
      return ROWS * COLS;
    endfunction
  endclass

  // Parameterized class with default override
  class Counter #(int MAX_COUNT = 100, int STEP = 1);
    int count;

    function new();
      count = 0;
    endfunction

    function void increment();
      if (count + STEP <= MAX_COUNT)
        count += STEP;
    endfunction

    function void decrement();
      if (count - STEP >= 0)
        count -= STEP;
    endfunction

    function void reset();
      count = 0;
    endfunction

    function int value();
      return count;
    endfunction

    function int max_val();
      return MAX_COUNT;
    endfunction
  endclass

  initial begin
    Stack #(4) small_stack;
    Stack #(16) large_stack;
    Stack default_stack;  // Uses default DEPTH=8
    Matrix #(3, 4) m34;
    Matrix default_matrix;  // 2x2
    Counter #(50, 5) counter;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Parameterized stack with small depth
    small_stack = new();
    small_stack.push(1);
    small_stack.push(2);
    small_stack.push(3);
    small_stack.push(4);
    if (!small_stack.push(5) && small_stack.capacity() == 4) begin
      $display("PASS: Test 1 - Small stack (DEPTH=4) works correctly");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Small stack failed");
      fail_count++;
    end

    // Test 2: Parameterized stack with large depth
    large_stack = new();
    if (large_stack.capacity() == 16 && large_stack.is_empty()) begin
      $display("PASS: Test 2 - Large stack (DEPTH=16) has correct capacity");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Large stack failed");
      fail_count++;
    end

    // Test 3: Default parameter value
    default_stack = new();
    if (default_stack.capacity() == 8) begin
      $display("PASS: Test 3 - Default parameter (DEPTH=8) works");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Default parameter failed: %0d", default_stack.capacity());
      fail_count++;
    end

    // Test 4: Multiple parameters
    m34 = new();
    m34.set(2, 3, 42);
    if (m34.rows() == 3 && m34.cols() == 4 && m34.get(2, 3) == 42 && m34.total_cells() == 12) begin
      $display("PASS: Test 4 - Multiple parameters (3x4 matrix) work");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Multiple parameters failed");
      fail_count++;
    end

    // Test 5: Counter with custom MAX and STEP
    counter = new();
    counter.increment();  // 0 + 5 = 5
    counter.increment();  // 5 + 5 = 10
    counter.increment();  // 10 + 5 = 15
    if (counter.value() == 15 && counter.max_val() == 50) begin
      $display("PASS: Test 5 - Counter with custom parameters");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Counter failed: %0d", counter.value());
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All parameterized class tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
