/*
:name: test_dynamic_array_edge
:description: Dynamic array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5.2 7.5.3 7.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_edge.expected
*/
// IEEE 1800-2023 §7.5: Dynamic array edge cases
`timescale 1ns/1ps

module test_dynamic_array_edge;
  int dyn_arr[];
  int dyn_arr2[];
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Empty dynamic array
    if (dyn_arr.size() != 0) begin
      $display("FAIL: Initial size should be 0");
      test_passed = 0;
    end

    // Test 2: new() with size
    dyn_arr = new[5];
    if (dyn_arr.size() != 5) begin
      $display("FAIL: After new[5], size should be 5");
      test_passed = 0;
    end

    // Test 3: Initialize values
    foreach (dyn_arr[i]) dyn_arr[i] = i * 10;
    if (dyn_arr[3] != 30) begin
      $display("FAIL: dyn_arr[3] should be 30");
      test_passed = 0;
    end

    // Test 4: Resize with preservation
    dyn_arr = new[10](dyn_arr);
    if (dyn_arr[3] != 30) begin
      $display("FAIL: Value not preserved after resize");
      test_passed = 0;
    end
    if (dyn_arr.size() != 10) begin
      $display("FAIL: Size should be 10 after resize");
      test_passed = 0;
    end

    // Test 5: Shrink with truncation
    dyn_arr = new[3](dyn_arr);
    if (dyn_arr.size() != 3) begin
      $display("FAIL: Size should be 3 after shrink");
      test_passed = 0;
    end
    if (dyn_arr[2] != 20) begin
      $display("FAIL: dyn_arr[2] should be 20");
      test_passed = 0;
    end

    // Test 6: delete()
    dyn_arr.delete();
    if (dyn_arr.size() != 0) begin
      $display("FAIL: Size should be 0 after delete");
      test_passed = 0;
    end

    // Test 7: Copy assignment
    dyn_arr = new[3];
    dyn_arr[0] = 100;
    dyn_arr[1] = 200;
    dyn_arr[2] = 300;
    dyn_arr2 = dyn_arr;
    dyn_arr[0] = 999;  // Modify original
    if (dyn_arr2[0] != 100) begin
      $display("FAIL: Copy should be independent");
      test_passed = 0;
    end

    // Test 8: Large dynamic array
    dyn_arr = new[100];
    for (int i = 0; i < 100; i++) dyn_arr[i] = i;
    if (dyn_arr[99] != 99) begin
      $display("FAIL: Large array access failed");
      test_passed = 0;
    end

    // Test 9: Resize to smaller
    dyn_arr = new[10](dyn_arr);
    if (dyn_arr.size() != 10 || dyn_arr[9] != 9) begin
      $display("FAIL: Resize to smaller failed");
      test_passed = 0;
    end

    // Test 10: new with zero size
    dyn_arr = new[0];
    if (dyn_arr.size() != 0) begin
      $display("FAIL: new[0] should create empty array");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Dynamic array edge cases");
    end else begin
      $display("FAIL: Some dynamic array tests failed");
    end
    $finish;
  end
endmodule
