/*
:name: test_mailbox_edge_cases
:description: Mailbox edge cases
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_edge_cases.expected
*/
// IEEE 1800-2023 Section 15.4 - Mailbox edge cases
// Tests corner cases for mailbox operations

module test_mailbox_edge_cases;
    mailbox #(int) mb;
    mailbox #(string) str_mb;
    int msg;
    string str_msg;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("IEEE 1800-2023 Section 15.4 - Mailbox Edge Cases Test");
        $display("============================================================");

        // Test 1: Create unbounded mailbox
        mb = new();
        if (mb != null) begin
            $display("PASS: Test 1 - Unbounded mailbox created");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Mailbox creation failed");
            fail_count++;
        end

        // Test 2: Empty mailbox num()
        mb = new();
        if (mb.num() == 0) begin
            $display("PASS: Test 2 - Empty mailbox num() = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected num()=0, got %0d", mb.num());
            fail_count++;
        end

        // Test 3: put() and num() count
        mb = new();
        mb.put(100);
        mb.put(200);
        mb.put(300);
        if (mb.num() == 3) begin
            $display("PASS: Test 3 - After 3 puts, num() = 3");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected num()=3, got %0d", mb.num());
            fail_count++;
        end

        // Test 4: get() retrieves in FIFO order
        mb = new();
        mb.put(1);
        mb.put(2);
        mb.put(3);
        mb.get(msg);
        if (msg == 1) begin
            $display("PASS: Test 4 - get() retrieves FIFO (first = 1)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 1, got %0d", msg);
            fail_count++;
        end

        // Test 5: try_get() with available message
        mb = new();
        mb.put(42);
        if (mb.try_get(msg) && msg == 42) begin
            $display("PASS: Test 5 - try_get() succeeds when message available");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - try_get() should have returned 42");
            fail_count++;
        end

        // Test 6: try_get() on empty mailbox
        mb = new();
        if (!mb.try_get(msg)) begin
            $display("PASS: Test 6 - try_get() returns 0 on empty mailbox");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - try_get() should fail on empty mailbox");
            fail_count++;
        end

        // Test 7: peek() doesn't remove message
        mb = new();
        mb.put(99);
        mb.peek(msg);
        if (msg == 99 && mb.num() == 1) begin
            $display("PASS: Test 7 - peek() returns message without removing");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - peek() should not remove message");
            fail_count++;
        end

        // Test 8: try_peek() on empty mailbox
        mb = new();
        if (!mb.try_peek(msg)) begin
            $display("PASS: Test 8 - try_peek() returns 0 on empty mailbox");
            pass_count++;
        end else begin
            $display("FAIL: Test 8 - try_peek() should fail on empty mailbox");
            fail_count++;
        end

        // Test 9: Bounded mailbox
        mb = new(2);  // Max 2 messages
        mb.put(1);
        mb.put(2);
        // try_put should fail when full
        if (!mb.try_put(3)) begin
            $display("PASS: Test 9 - Bounded mailbox rejects when full");
            pass_count++;
        end else begin
            $display("FAIL: Test 9 - Bounded mailbox should reject 3rd message");
            fail_count++;
        end

        // Test 10: String mailbox
        str_mb = new();
        str_mb.put("hello");
        str_mb.put("world");
        str_mb.get(str_msg);
        if (str_msg == "hello") begin
            $display("PASS: Test 10 - String mailbox works");
            pass_count++;
        end else begin
            $display("FAIL: Test 10 - Expected 'hello', got '%s'", str_msg);
            fail_count++;
        end

        // Summary
        $display("============================================================");
        $display("Test Summary: %0d passed, %0d failed", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end

        $finish;
    end
endmodule
