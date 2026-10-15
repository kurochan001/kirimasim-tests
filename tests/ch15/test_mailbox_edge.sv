/*
:name: test_mailbox_edge
:description: Mailbox edge cases
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_edge.expected
*/
// IEEE 1800-2023 §15.4: Mailbox edge cases
`timescale 1ns/1ps

module test_mailbox_edge;
  mailbox #(int) mb;
  mailbox #(int) bounded_mb;
  int val;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Unbounded mailbox
    mb = new();

    // Test 2: Put multiple items
    for (int i = 0; i < 10; i++) begin
      mb.put(i * 10);
    end
    $display("Test 2: Put 10 items");

    // Test 3: Check num()
    if (mb.num() != 10) begin
      $display("FAIL: num() expected 10, got %0d", mb.num());
      test_passed = 0;
    end

    // Test 4: Get items in FIFO order
    for (int i = 0; i < 10; i++) begin
      mb.get(val);
      if (val != i * 10) begin
        $display("FAIL: Expected %0d, got %0d", i * 10, val);
        test_passed = 0;
      end
    end

    // Test 5: try_get on empty mailbox
    if (mb.try_get(val)) begin
      $display("FAIL: try_get should fail on empty mailbox");
      test_passed = 0;
    end

    // Test 6: Bounded mailbox
    bounded_mb = new(3);

    // Test 7: Fill bounded mailbox
    bounded_mb.put(1);
    bounded_mb.put(2);
    bounded_mb.put(3);
    $display("Test 7: Filled bounded mailbox with 3 items");

    // Test 8: try_put on full bounded mailbox
    if (bounded_mb.try_put(4)) begin
      $display("FAIL: try_put should fail on full bounded mailbox");
      test_passed = 0;
    end

    // Test 9: Get one and try_put again
    bounded_mb.get(val);
    if (!bounded_mb.try_put(4)) begin
      $display("FAIL: try_put should succeed after get");
      test_passed = 0;
    end

    // Test 10: peek without removing
    mb = new();
    mb.put(100);
    mb.put(200);
    mb.peek(val);
    if (val != 100) begin
      $display("FAIL: peek expected 100, got %0d", val);
      test_passed = 0;
    end
    if (mb.num() != 2) begin
      $display("FAIL: peek should not remove item");
      test_passed = 0;
    end

    // Test 11: try_peek on empty
    mb = new();
    if (mb.try_peek(val)) begin
      $display("FAIL: try_peek should fail on empty mailbox");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Mailbox edge cases");
    end else begin
      $display("FAIL: Some mailbox tests failed");
    end
    $finish;
  end
endmodule
