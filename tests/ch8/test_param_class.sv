/*
:name: test_param_class
:description: Test parameterized class (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class.expected
*/
// Test parameterized class (IEEE 1800-2023 Section 8.25)

class Stack #(type T = int, int SIZE = 10);
  T data[SIZE];
  int top;

  function new();
    top = 0;
  endfunction

  function void push(T val);
    if (top < SIZE) begin
      data[top] = val;
      top++;
    end
  endfunction

  function T pop();
    if (top > 0) begin
      top--;
      return data[top];
    end
    return T'(0);
  endfunction
endclass

module test_param_class;
  Stack #(int, 5) int_stack;
  int pass_count;

  initial begin
    pass_count = 0;
    int_stack = new();

    // Test 1: Push and pop
    int_stack.push(42);
    if (int_stack.pop() == 42) pass_count++;

    // Test 2: Multiple push/pop
    int_stack.push(10);
    int_stack.push(20);
    if (int_stack.pop() == 20) pass_count++;

    // Test 3: LIFO order
    if (int_stack.pop() == 10) pass_count++;

    $display("Param class tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Param class tests");
    end else begin
      $display("FAIL: Some param class tests failed");
    end
  end
endmodule
