/*
:name: test_assoc_array_iterate
:description: Test for associative array iteration (IEEE 1800-2023 §7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9 7.9.4 7.9.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_iterate.expected
*/
// Test for associative array iteration (IEEE 1800-2023 §7.8)

module test_assoc_array_iterate;
  int aa[string];
  int passed;

  initial begin
    passed = 0;

    // Initialize
    aa = '{"apple": 1, "banana": 2, "cherry": 3};

    // Test 1: Forward iteration with first/next
    $display("Test 1: Forward iteration");
    begin
      string key;
      static int count = 0;
      if (aa.first(key)) begin
        do begin
          $display("    %s: %0d", key, aa[key]);
          count++;
        end while (aa.next(key));
      end
      if (count == 3) begin
        $display("  PASS: forward %0d items", count);
        passed++;
      end else begin
        $display("  FAIL: forward %0d items", count);
      end
    end

    // Test 2: Backward iteration with last/prev
    $display("Test 2: Backward iteration");
    begin
      string key;
      static int count = 0;
      if (aa.last(key)) begin
        $display("    Last key: %s", key);
        count++;
        while (aa.prev(key)) begin
          $display("    Prev key: %s", key);
          count++;
        end
      end
      if (count == 3) begin
        $display("  PASS: backward %0d items", count);
        passed++;
      end else begin
        $display("  FAIL: backward %0d items", count);
      end
    end

    // Test 3: Empty array iteration
    $display("Test 3: Empty array iteration");
    aa.delete();
    begin
      string key;
      if (!aa.first(key)) begin
        $display("  PASS: first() returns 0 for empty");
        passed++;
      end else begin
        $display("  FAIL");
      end
    end

    // Test 4: Single element iteration
    $display("Test 4: Single element iteration");
    aa["only"] = 42;
    begin
      string key;
      if (aa.first(key) && !aa.next(key)) begin
        $display("  PASS: single element iteration");
        passed++;
      end else begin
        $display("  FAIL: single element behavior");
      end
    end

    if (passed == 4) begin
      $display("TEST PASSED: %0d/4 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/4 tests passed", passed);
    end
    $finish;
  end
endmodule
