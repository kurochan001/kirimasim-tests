/*
:name: test_func_call_deep
:description: tasks and functions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_call_deep.expected
*/
// IEEE 1800-2023 §13 tasks and functions

module tb;
  int pass_count = 0;
  int fail_count = 0;

  // Class definitions at module scope (§8.3)
  class Base;
    virtual function int compute(int x);
      return x * 2;
    endfunction
  endclass

  class Derived extends Base;
    function int compute(int x);
      return x * 3;
    endfunction
  endclass

  // Test 1: Recursive function
  function automatic int factorial(int n);
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  endfunction

  // Test 2: Function with ref parameter
  function automatic void swap(ref int a, ref int b);
    int tmp = a;
    a = b;
    b = tmp;
  endfunction

  // Test 3: Function returning array element
  function automatic int get_element(int arr[], int idx);
    if (idx >= 0 && idx < arr.size())
      return arr[idx];
    else
      return -1;
  endfunction

  // Test 4: Function with default parameter
  function automatic int add(int a, int b = 10);
    return a + b;
  endfunction

  // Test 5: Static function variable
  function automatic int counter();
    static int count = 0;
    count++;
    return count;
  endfunction

  // Test 6: Function with string return
  function automatic string int_to_hex(int val);
    string s;
    $sformat(s, "%0h", val);
    return s;
  endfunction

  // Test 7: Function with queue parameter
  function automatic int sum_queue(int q[$]);
    int total = 0;
    foreach (q[i]) total += q[i];
    return total;
  endfunction

  initial begin
    int a, b;
    int arr[];
    int q[$];
    Base obj;
    Derived dobj;

    // Test recursive function
    if (factorial(5) == 120) begin
      pass_count++;
      $display("PASS: recursive function");
    end else begin
      fail_count++;
      $display("FAIL: recursive function: got %0d", factorial(5));
    end

    // Test ref parameter
    a = 10; b = 20;
    swap(a, b);
    if (a == 20 && b == 10) begin
      pass_count++;
      $display("PASS: ref parameter");
    end else begin
      fail_count++;
      $display("FAIL: ref parameter");
    end

    // Test array parameter
    arr = new[3];
    arr = '{100, 200, 300};
    if (get_element(arr, 1) == 200) begin
      pass_count++;
      $display("PASS: array parameter function");
    end else begin
      fail_count++;
      $display("FAIL: array parameter function");
    end

    // Test out-of-range
    if (get_element(arr, 10) == -1) begin
      pass_count++;
      $display("PASS: array OOR returns -1");
    end else begin
      fail_count++;
      $display("FAIL: array OOR");
    end

    // Test default parameter
    if (add(5) == 15 && add(5, 20) == 25) begin
      pass_count++;
      $display("PASS: default parameter");
    end else begin
      fail_count++;
      $display("FAIL: default parameter");
    end

    // Test static variable
    if (counter() == 1 && counter() == 2 && counter() == 3) begin
      pass_count++;
      $display("PASS: static variable");
    end else begin
      fail_count++;
      $display("FAIL: static variable");
    end

    // Test string return
    if (int_to_hex(255) == "ff") begin
      pass_count++;
      $display("PASS: string return function");
    end else begin
      fail_count++;
      $display("FAIL: string return: got '%s'", int_to_hex(255));
    end

    // Test virtual method dispatch
    dobj = new();
    obj = dobj;
    if (obj.compute(5) == 15) begin
      pass_count++;
      $display("PASS: virtual method dispatch");
    end else begin
      fail_count++;
      $display("FAIL: virtual method dispatch: got %0d", obj.compute(5));
    end

    // Test queue parameter
    q = '{1, 2, 3, 4, 5};
    if (sum_queue(q) == 15) begin
      pass_count++;
      $display("PASS: queue parameter");
    end else begin
      fail_count++;
      $display("FAIL: queue parameter");
    end

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
