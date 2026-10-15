/*
:name: test_mailbox_edge_cases_2
:description: Test: Mailbox edge cases
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_edge_cases_2.expected
*/
// Test: Mailbox edge cases
// IEEE 1800-2023 Section 15.4 Mailboxes
// Tests corner cases: mailbox operations

`timescale 1ns/1ps

module test_mailbox_edge_cases_2;
    int passed = 0;
    int failed = 0;

    mailbox #(int) mb;

    initial begin
        $display("TEST: Mailbox edge cases");

        // Test 1: Create mailbox
        begin
            mb = new();
            if (mb != null) begin
                $display("  [PASS] Create mailbox");
                passed++;
            end else begin
                $display("  [FAIL] Create");
                failed++;
            end
        end

        // Test 2: Initial size
        begin
            if (mb.num() == 0) begin
                $display("  [PASS] Initial size");
                passed++;
            end else begin
                $display("  [FAIL] InitSize: %0d", mb.num());
                failed++;
            end
        end

        // Test 3: Put message
        begin
            mb.put(10);
            if (mb.num() == 1) begin
                $display("  [PASS] Put message");
                passed++;
            end else begin
                $display("  [FAIL] Put: %0d", mb.num());
                failed++;
            end
        end

        // Test 4: Get message
        begin
            int val;
            mb.get(val);
            if (val == 10 && mb.num() == 0) begin
                $display("  [PASS] Get message");
                passed++;
            end else begin
                $display("  [FAIL] Get: %0d", val);
                failed++;
            end
        end

        // Test 5: Multiple put
        begin
            mb.put(1);
            mb.put(2);
            mb.put(3);
            if (mb.num() == 3) begin
                $display("  [PASS] Multiple put");
                passed++;
            end else begin
                $display("  [FAIL] MultiPut: %0d", mb.num());
                failed++;
            end
        end

        // Test 6: FIFO order
        begin
            int v1, v2, v3;
            mb.get(v1);
            mb.get(v2);
            mb.get(v3);
            if (v1 == 1 && v2 == 2 && v3 == 3) begin
                $display("  [PASS] FIFO order");
                passed++;
            end else begin
                $display("  [FAIL] FIFO: %0d %0d %0d", v1, v2, v3);
                failed++;
            end
        end

        // Test 7: Peek message
        begin
            int peeked;
            mb.put(42);
            mb.peek(peeked);
            if (peeked == 42 && mb.num() == 1) begin
                $display("  [PASS] Peek message");
                passed++;
            end else begin
                $display("  [FAIL] Peek: %0d", peeked);
                failed++;
            end
        end

        // Test 8: Try get success
        begin
            int val;
            int result;
            result = mb.try_get(val);
            if (result > 0 && val == 42) begin
                $display("  [PASS] Try get success");
                passed++;
            end else begin
                $display("  [FAIL] TryGet: %0d", result);
                failed++;
            end
        end

        // Test 9: Try get empty
        begin
            int val;
            int result;
            result = mb.try_get(val);
            if (result == 0) begin
                $display("  [PASS] Try get empty");
                passed++;
            end else begin
                $display("  [FAIL] TryEmpty: %0d", result);
                failed++;
            end
        end

        // Test 10: Large value
        begin
            int val;
            mb.put(999999);
            mb.get(val);
            if (val == 999999) begin
                $display("  [PASS] Large value");
                passed++;
            end else begin
                $display("  [FAIL] Large: %0d", val);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
