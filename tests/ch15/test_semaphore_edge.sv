/*
:name: test_semaphore_edge
:description: Semaphore edge cases
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_edge.expected
*/
// IEEE 1800-2023 §15.3: Semaphore edge cases
`timescale 1ns/1ps

module test_semaphore_edge;
  semaphore sem;
  int counter;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Create semaphore with initial keys
    sem = new(3);

    // Test 2: Get all keys
    sem.get(3);
    $display("Test 2: Got all 3 keys");

    // Test 3: Put keys back
    sem.put(3);
    $display("Test 3: Put 3 keys back");

    // Test 4: try_get success
    if (!sem.try_get(2)) begin
      $display("FAIL: try_get(2) should succeed");
      test_passed = 0;
    end

    // Test 5: try_get partial (should fail - only 1 key left)
    if (sem.try_get(2)) begin
      $display("FAIL: try_get(2) should fail with only 1 key");
      test_passed = 0;
    end

    // Test 6: try_get exactly available
    if (!sem.try_get(1)) begin
      $display("FAIL: try_get(1) should succeed with 1 key");
      test_passed = 0;
    end

    // Test 7: try_get when empty
    if (sem.try_get(1)) begin
      $display("FAIL: try_get(1) should fail when empty");
      test_passed = 0;
    end

    // Test 8: Put multiple and verify
    sem.put(5);
    if (!sem.try_get(5)) begin
      $display("FAIL: Should have 5 keys after put(5)");
      test_passed = 0;
    end

    // Test 9: Create with 0 initial keys
    sem = new(0);
    if (sem.try_get(1)) begin
      $display("FAIL: Semaphore with 0 keys should fail try_get");
      test_passed = 0;
    end

    // Test 10: Large key count
    sem = new(1000);
    if (!sem.try_get(1000)) begin
      $display("FAIL: Should get all 1000 keys");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Semaphore edge cases");
    end else begin
      $display("FAIL: Some semaphore tests failed");
    end
    $finish;
  end
endmodule
