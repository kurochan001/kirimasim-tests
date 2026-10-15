/*
:name: test_statement_foreach
:description: Test for foreach statement (IEEE 1800-2023 §12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_foreach.expected
*/
// Test for foreach statement (IEEE 1800-2023 §12.7.3)

module test_statement_foreach;
  int arr[5];
  int arr2d[3][4];
  int queue[$];
  int passed;

  initial begin
    passed = 0;

    // Initialize array
    arr = '{10, 20, 30, 40, 50};

    // Test 1: Simple foreach
    $display("Test 1: Simple foreach");
    begin
      int sum;
      sum = 0;
      foreach (arr[i]) begin
        sum = sum + arr[i];
      end
      if (sum == 150) begin
        $display("  PASS: sum = %0d", sum);
        passed++;
      end else begin
        $display("  FAIL: expected 150, got %0d", sum);
      end
    end

    // Test 2: Foreach with index use
    $display("Test 2: Foreach with index");
    begin
      int idx_sum;
      idx_sum = 0;
      foreach (arr[i]) begin
        idx_sum = idx_sum + i;
      end
      if (idx_sum == 10) begin  // 0+1+2+3+4
        $display("  PASS: index sum = %0d", idx_sum);
        passed++;
      end else begin
        $display("  FAIL: expected 10, got %0d", idx_sum);
      end
    end

    // Test 3: 2D array foreach
    $display("Test 3: 2D array foreach");
    foreach (arr2d[i,j]) begin
      arr2d[i][j] = i * 4 + j;
    end
    if (arr2d[2][3] == 11) begin
      $display("  PASS: arr2d[2][3] = %0d", arr2d[2][3]);
      passed++;
    end else begin
      $display("  FAIL: expected 11, got %0d", arr2d[2][3]);
    end

    // Test 4: Queue foreach
    $display("Test 4: Queue foreach");
    queue.push_back(100);
    queue.push_back(200);
    queue.push_back(300);
    begin
      int sum;
      sum = 0;
      foreach (queue[i]) begin
        sum = sum + queue[i];
      end
      if (sum == 600) begin
        $display("  PASS: queue sum = %0d", sum);
        passed++;
      end else begin
        $display("  FAIL: expected 600, got %0d", sum);
      end
    end

    // Test 5: Foreach with modification
    $display("Test 5: Foreach with modification");
    foreach (arr[i]) begin
      arr[i] = arr[i] * 2;
    end
    if (arr[0] == 20 && arr[4] == 100) begin
      $display("  PASS: modified arr[0]=%0d, arr[4]=%0d", arr[0], arr[4]);
      passed++;
    end else begin
      $display("  FAIL: arr[0]=%0d, arr[4]=%0d", arr[0], arr[4]);
    end

    if (passed == 5) begin
      $display("TEST PASSED: %0d/5 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/5 tests passed", passed);
    end
    $finish;
  end
endmodule
