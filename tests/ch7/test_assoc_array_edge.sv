/*
:name: test_assoc_array_edge
:description: Associative array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9 7.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_edge.expected
*/
// IEEE 1800-2023 §7.8: Associative array edge cases
`timescale 1ns/1ps

module test_assoc_array_edge;
  int aa_int[int];
  string aa_str[string];
  int aa_wildcard[*];
  int val;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Empty associative array
    if (aa_int.size() != 0) begin
      $display("FAIL: Initial size should be 0");
      test_passed = 0;
    end

    // Test 2: exists() on empty
    if (aa_int.exists(0)) begin
      $display("FAIL: exists() should return 0 for empty array");
      test_passed = 0;
    end

    // Test 3: Insert elements
    aa_int[10] = 100;
    aa_int[20] = 200;
    aa_int[30] = 300;
    if (aa_int.size() != 3) begin
      $display("FAIL: Size should be 3");
      test_passed = 0;
    end

    // Test 4: exists() after insert
    if (!aa_int.exists(20)) begin
      $display("FAIL: exists(20) should return 1");
      test_passed = 0;
    end

    // Test 5: first() and last()
    if (!aa_int.first(val) || val != 10) begin
      $display("FAIL: first() should return 10");
      test_passed = 0;
    end
    if (!aa_int.last(val) || val != 30) begin
      $display("FAIL: last() should return 30");
      test_passed = 0;
    end

    // Test 6: next() and prev()
    val = 10;
    if (!aa_int.next(val) || val != 20) begin
      $display("FAIL: next(10) should return 20");
      test_passed = 0;
    end
    val = 30;
    if (!aa_int.prev(val) || val != 20) begin
      $display("FAIL: prev(30) should return 20");
      test_passed = 0;
    end

    // Test 7: delete() single element
    aa_int.delete(20);
    if (aa_int.exists(20)) begin
      $display("FAIL: Element 20 should be deleted");
      test_passed = 0;
    end
    if (aa_int.size() != 2) begin
      $display("FAIL: Size should be 2 after delete");
      test_passed = 0;
    end

    // Test 8: delete() all
    aa_int.delete();
    if (aa_int.size() != 0) begin
      $display("FAIL: Size should be 0 after delete all");
      test_passed = 0;
    end

    // Test 9: String key
    aa_str["hello"] = "world";
    aa_str["foo"] = "bar";
    if (aa_str["hello"] != "world") begin
      $display("FAIL: String key lookup failed");
      test_passed = 0;
    end

    // Test 10: Negative key
    aa_int[-100] = 999;
    aa_int[-50] = 888;
    if (aa_int[-100] != 999) begin
      $display("FAIL: Negative key failed");
      test_passed = 0;
    end

    // Test 11: Large sparse keys
    aa_int[1000000] = 1;
    aa_int[2000000] = 2;
    if (aa_int.size() != 4) begin
      $display("FAIL: Sparse keys size wrong");
      test_passed = 0;
    end

    // Test 12: num() alias
    if (aa_int.num() != aa_int.size()) begin
      $display("FAIL: num() should equal size()");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Associative array edge cases");
    end else begin
      $display("FAIL: Some associative array tests failed");
    end
    $finish;
  end
endmodule
