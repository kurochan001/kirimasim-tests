/*
:name: test_nested_member_access
:description: Test case: Nested class member access (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_member_access.expected
*/
// Test case: Nested class member access (IEEE 1800-2023 Section 8.3)
// This tests that nested member access like list.head.value correctly
// evaluates in assignment and comparison contexts

module test_nested_member_access;

    // Simple Node class with value
    class Node;
        int value;
        Node next;

        function new(int v);
            value = v;
            next = null;
        endfunction
    endclass

    // Container class with Node member
    class LinkedList;
        Node head;

        function void add(int v);
            Node n = new(v);
            n.next = head;
            head = n;
        endfunction
    endclass

    // Deeply nested class
    class DeepNest;
        DeepNest inner;
        int data;

        function new(int d);
            data = d;
            inner = null;
        endfunction
    endclass

    int test_count = 0;
    int pass_count = 0;

    initial begin
        // Test 1: Two-level member access with inline new
        begin
            LinkedList list;
            int v;

            list = new();
            list.head = new(42);

            test_count++;
            v = list.head.value;
            if (v == 42) begin
                $display("TEST 1 PASSED: list.head.value assignment = %0d", v);
                pass_count++;
            end else begin
                $display("TEST 1 FAILED: list.head.value = %0d (expected 42)", v);
            end
        end

        // Test 2: Two-level member access in comparison
        begin
            LinkedList list;

            list = new();
            list.head = new(100);

            test_count++;
            if (list.head.value == 100) begin
                $display("TEST 2 PASSED: list.head.value comparison works");
                pass_count++;
            end else begin
                $display("TEST 2 FAILED: list.head.value != 100");
            end
        end

        // Test 3: Three-level member access (list.head.next.value)
        begin
            LinkedList list;

            list = new();
            list.add(10);
            list.add(20);
            list.add(30);

            test_count++;
            if (list.head.value == 30) begin
                $display("TEST 3 PASSED: list.head.value = 30 (most recent)");
                pass_count++;
            end else begin
                $display("TEST 3 FAILED: list.head.value = %0d (expected 30)", list.head.value);
            end

            test_count++;
            if (list.head.next.value == 20) begin
                $display("TEST 4 PASSED: list.head.next.value = 20");
                pass_count++;
            end else begin
                $display("TEST 4 FAILED: list.head.next.value = %0d (expected 20)", list.head.next.value);
            end

            test_count++;
            if (list.head.next.next.value == 10) begin
                $display("TEST 5 PASSED: list.head.next.next.value = 10");
                pass_count++;
            end else begin
                $display("TEST 5 FAILED: list.head.next.next.value = %0d (expected 10)", list.head.next.next.value);
            end
        end

        // Test 4: Deep nesting (4 levels)
        begin
            DeepNest d1, d2, d3, d4, d5;
            int v;

            d1 = new(1);
            d2 = new(2);
            d3 = new(3);
            d4 = new(4);
            d5 = new(5);

            d1.inner = d2;
            d2.inner = d3;
            d3.inner = d4;
            d4.inner = d5;

            test_count++;
            v = d1.inner.inner.inner.inner.data;
            if (v == 5) begin
                $display("TEST 6 PASSED: 4-level deep access = %0d", v);
                pass_count++;
            end else begin
                $display("TEST 6 FAILED: 4-level deep access = %0d (expected 5)", v);
            end
        end

        // Test 5: Assignment via intermediate variable (should still work)
        begin
            LinkedList list;
            Node temp;
            int v;

            list = new();
            list.head = new(77);

            temp = list.head;
            v = temp.value;

            test_count++;
            if (v == 77) begin
                $display("TEST 7 PASSED: temp.value = %0d (via intermediate)", v);
                pass_count++;
            end else begin
                $display("TEST 7 FAILED: temp.value = %0d (expected 77)", v);
            end
        end

        // Summary
        $display("");
        $display("=== Test Summary ===");
        $display("Passed: %0d / %0d", pass_count, test_count);

        if (pass_count == test_count)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
