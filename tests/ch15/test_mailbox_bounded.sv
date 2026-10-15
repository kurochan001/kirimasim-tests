/*
:name: test_mailbox_bounded
:description: Bounded mailbox: try_put on a full mailbox, try_peek and try_get
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_bounded.expected
*/
// IEEE 1800-2023 §15.4 Mailboxes
// Test: Bounded mailbox operations
module test_mailbox_bounded;
    mailbox #(int) mb;
    int errors = 0;
    int received;

    initial begin
        // Test 1: Create bounded mailbox with capacity 3
        mb = new(3);

        if (mb.num() !== 0) begin
            $display("FAIL: Initial mailbox should be empty, num=%0d", mb.num());
            errors++;
        end

        // Test 2: Put items up to capacity
        mb.put(10);
        mb.put(20);
        mb.put(30);

        if (mb.num() !== 3) begin
            $display("FAIL: After 3 puts, num should be 3, got %0d", mb.num());
            errors++;
        end

        // Test 3: try_put when full (should fail)
        if (mb.try_put(40) != 0) begin
            $display("FAIL: try_put on full mailbox should return 0");
            errors++;
        end

        if (mb.num() !== 3) begin
            $display("FAIL: After failed try_put, num should still be 3");
            errors++;
        end

        // Test 4: Get items (FIFO order)
        mb.get(received);
        if (received !== 10) begin
            $display("FAIL: First get should be 10, got %0d", received);
            errors++;
        end

        mb.get(received);
        if (received !== 20) begin
            $display("FAIL: Second get should be 20, got %0d", received);
            errors++;
        end

        // Test 5: Peek without removing
        if (mb.try_peek(received) <= 0) begin
            $display("FAIL: try_peek should succeed");
            errors++;
        end
        if (received !== 30) begin
            $display("FAIL: Peek should see 30, got %0d", received);
            errors++;
        end
        if (mb.num() !== 1) begin
            $display("FAIL: After peek, num should still be 1");
            errors++;
        end

        // Test 6: Get remaining item
        mb.get(received);
        if (received !== 30) begin
            $display("FAIL: Third get should be 30, got %0d", received);
            errors++;
        end

        // Test 7: try_get on empty (should fail)
        if (mb.try_get(received) != 0) begin
            $display("FAIL: try_get on empty mailbox should return 0");
            errors++;
        end

        // Test 8: Refill and verify capacity still works
        mb.put(100);
        mb.put(200);
        mb.put(300);
        if (mb.try_put(400) != 0) begin
            $display("FAIL: Mailbox should be full again");
            errors++;
        end

        if (errors == 0) begin
            $display("TEST PASSED: Bounded mailbox tests passed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
