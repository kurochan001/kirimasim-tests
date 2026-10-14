/*
:name: test_class_method_control_flow
:description: Class methods that return from loops, nested if-else and case statements (IEEE 1800-2023 Sections 8.6, 13.4.1 and 12.8)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 13.4.1 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_method_control_flow.expected
*/
// IEEE 1800-2023 Sections 8.6, 13.4.1 and 12.8
// Class method return through complex control flow paths
module test_class_method_control_flow;

  int pass_count = 0;
  int fail_count = 0;

  task check(string name, int condition);
    if (condition) pass_count++;
    else begin fail_count++; $display("FAIL: %s", name); end
  endtask

  class Calculator;
    int accumulator;

    function new();
      accumulator = 0;
    endfunction

    // Return inside for loop
    function int find_first_gt(int arr[], int threshold);
      for (int i = 0; i < arr.size(); i++) begin
        if (arr[i] > threshold)
          return arr[i];
      end
      return -1;
    endfunction

    // Return inside while loop
    function int count_until(int limit);
      int cnt = 0;
      while (cnt < 100) begin
        if (cnt >= limit)
          return cnt;
        cnt++;
      end
      return cnt;
    endfunction

    // Return inside nested if-else
    function int classify(int val);
      if (val < 0) begin
        if (val < -100)
          return -2;
        else
          return -1;
      end else if (val == 0) begin
        return 0;
      end else begin
        if (val > 100)
          return 2;
        else
          return 1;
      end
    endfunction

    // Return inside case statement
    function string status_name(int code);
      case (code)
        0: return "idle";
        1: return "running";
        2: return "stopped";
        3: return "error";
        default: return "unknown";
      endcase
    endfunction

    // Return inside foreach
    function int sum_positive(int arr[]);
      int total = 0;
      foreach (arr[i]) begin
        if (arr[i] > 0)
          total += arr[i];
      end
      return total;
    endfunction

    // Multiple early returns
    function int safe_divide(int a, int b);
      if (b == 0) return 0;
      if (a == 0) return 0;
      return a / b;
    endfunction

    // Return after loop completes
    function int find_last(int arr[], int val);
      int last_idx = -1;
      for (int i = 0; i < arr.size(); i++) begin
        if (arr[i] == val)
          last_idx = i;
      end
      return last_idx;
    endfunction

    // Void method with early return
    task accumulate(int vals[]);
      foreach (vals[i]) begin
        accumulator += vals[i];
      end
    endtask
  endclass

  initial begin
    static Calculator calc = new();
    static int arr5[] = '{3, 7, 2, 9, 1};
    static int arr4[] = '{-5, 10, -3, 20};

    // Test 1: find first greater than threshold
    check("find_gt_found", calc.find_first_gt(arr5, 5) == 7);
    check("find_gt_not_found", calc.find_first_gt(arr5, 100) == -1);
    check("find_gt_first", calc.find_first_gt(arr5, 0) == 3);

    // Test 2: count until limit
    check("count_until_5", calc.count_until(5) == 5);
    check("count_until_0", calc.count_until(0) == 0);
    check("count_until_50", calc.count_until(50) == 50);

    // Test 3: classify
    check("classify_neg", calc.classify(-50) == -1);
    check("classify_very_neg", calc.classify(-200) == -2);
    check("classify_zero", calc.classify(0) == 0);
    check("classify_pos", calc.classify(50) == 1);
    check("classify_very_pos", calc.classify(200) == 2);

    // Test 4: status name
    check("status_idle", calc.status_name(0) == "idle");
    check("status_running", calc.status_name(1) == "running");
    check("status_error", calc.status_name(3) == "error");
    check("status_unknown", calc.status_name(99) == "unknown");

    // Test 5: sum positive
    check("sum_positive", calc.sum_positive(arr4) == 30);

    // Test 6: safe divide
    check("safe_div_normal", calc.safe_divide(10, 3) == 3);
    check("safe_div_zero_b", calc.safe_divide(10, 0) == 0);
    check("safe_div_zero_a", calc.safe_divide(0, 5) == 0);

    // Test 7: find last
    begin
      static int arr6[] = '{1, 2, 3, 2, 1};
      check("find_last_2", calc.find_last(arr6, 2) == 3);
      check("find_last_1", calc.find_last(arr6, 1) == 4);
      check("find_last_none", calc.find_last(arr6, 9) == -1);
    end

    // Test 8: accumulate task
    begin
      calc.accumulator = 0;
      calc.accumulate(arr5);
      check("accumulate", calc.accumulator == 22);
    end

    // Test 9: chained method calls
    begin
      static int r1;
      static int r2;
      // Assigned here so the result does not depend on the order of static initializers.
      r1 = calc.find_first_gt(arr5, 0);
      r2 = calc.classify(r1);
      check("chained_method", r2 == 1);
    end

    // Test 10: method call in expression
    begin
      static int val;
      // Assigned here so the result does not depend on the order of static initializers.
      val = calc.safe_divide(calc.sum_positive(arr4), 2);
      check("method_in_expr", val == 15);
    end

    $display("%0d passed, %0d failed (total %0d)", pass_count, fail_count, pass_count + fail_count);
    if (fail_count == 0) $display("TEST PASSED");
    else $display("TEST FAILED");
    $finish;
  end
endmodule
