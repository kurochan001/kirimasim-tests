/*
:name: test_generate_loop_function_call
:description: Test for generate with function calls (IEEE 1800-2023 §27.4)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop_function_call.expected
*/
// Test for generate with function calls (IEEE 1800-2023 §27.4)
// Tests generate blocks with function invocations

module test_generate_loop_function_call;

  parameter int NUM_INSTANCES = 4;
  int results[NUM_INSTANCES];
  int pass_count = 0;
  int test_count = 0;

  // Function to compute value
  function automatic int compute_value(input int idx);
    return idx * 10 + 5;
  endfunction

  // Generate multiple function calls
  generate
    genvar i;
    for (i = 0; i < NUM_INSTANCES; i = i + 1) begin : func_gen
      // Only stores the value: the order of these initial blocks at time 0
      // is not defined, so the values are printed later from one block.
      initial results[i] = compute_value(i);
    end
  endgenerate

  initial begin
    #1;  // Wait for generate initial blocks
    for (int k = 0; k < NUM_INSTANCES; k++)
      $display("Instance[%0d]: compute_value(%0d) = %0d", k, k, results[k]);

    // Test 1: Check instance 0
    test_count = test_count + 1;
    if (results[0] == 5) begin
      $display("PASS: results[0] = %0d", results[0]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 5, got %0d", results[0]);
    end

    // Test 2: Check instance 1
    test_count = test_count + 1;
    if (results[1] == 15) begin
      $display("PASS: results[1] = %0d", results[1]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 15, got %0d", results[1]);
    end

    // Test 3: Check instance 2
    test_count = test_count + 1;
    if (results[2] == 25) begin
      $display("PASS: results[2] = %0d", results[2]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 25, got %0d", results[2]);
    end

    // Test 4: Check instance 3
    test_count = test_count + 1;
    if (results[3] == 35) begin
      $display("PASS: results[3] = %0d", results[3]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 35, got %0d", results[3]);
    end

    // Test 5: Verify all instances
    test_count = test_count + 1;
    begin
      static bit all_correct = 1;
      for (int k = 0; k < NUM_INSTANCES; k = k + 1) begin
        if (results[k] != k * 10 + 5) begin
          all_correct = 0;
          $display("MISMATCH: results[%0d] = %0d, expected %0d", k, results[k], k * 10 + 5);
        end
      end
      if (all_correct) begin
        $display("PASS: All %0d instances produce correct results", NUM_INSTANCES);
        pass_count = pass_count + 1;
      end else begin
        $display("FAIL: Some instances produce incorrect results");
      end
    end

    // Summary
    $display("");
    $display("=== Generate Function Call Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All generate function call tests passed");
    end else begin
      $display("FAIL: Some generate function call tests failed");
    end

    $finish;
  end

endmodule
