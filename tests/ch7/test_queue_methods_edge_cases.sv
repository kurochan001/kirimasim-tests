/*
:name: test_queue_methods_edge_cases
:description: Test: Queue edge cases - empty operations, boundary indices
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_edge_cases.expected
*/
// Test: Queue edge cases - empty operations, boundary indices
// Verifies queue insert/delete/pop with edge case inputs
module test;
    int pass_count = 0;

    initial begin
        // Test 1: Push and pop basic operations
        begin
            int q[$];
            q.push_back(10);
            q.push_back(20);
            q.push_back(30);
            if (q.size() == 3 && q[0] == 10 && q[2] == 30) begin
                $display("T1: PASS - basic push_back works");
                pass_count++;
            end else begin
                $display("T1: FAIL - push_back: size=%0d, q[0]=%0d, q[2]=%0d",
                    q.size(), q[0], q[2]);
            end
        end

        // Test 2: Pop from queue
        begin
            int q[$];
            q.push_back(10);
            q.push_back(20);
            q.push_back(30);
            begin
                static int v;
                // Assigned here so the result does not depend on the order of static initializers.
                v = q.pop_front();
                if (v == 10 && q.size() == 2) begin
                    $display("T2: PASS - pop_front returns 10, size=2");
                    pass_count++;
                end else begin
                    $display("T2: FAIL - pop_front: v=%0d, size=%0d", v, q.size());
                end
            end
        end

        // Test 3: Pop back from queue
        begin
            int q[$];
            q.push_back(10);
            q.push_back(20);
            q.push_back(30);
            begin
                static int v;
                // Assigned here so the result does not depend on the order of static initializers.
                v = q.pop_back();
                if (v == 30 && q.size() == 2) begin
                    $display("T3: PASS - pop_back returns 30, size=2");
                    pass_count++;
                end else begin
                    $display("T3: FAIL - pop_back: v=%0d, size=%0d", v, q.size());
                end
            end
        end

        // Test 4: Insert at beginning
        begin
            int q[$];
            q.push_back(20);
            q.push_back(30);
            q.insert(0, 10);
            if (q.size() == 3 && q[0] == 10 && q[1] == 20) begin
                $display("T4: PASS - insert(0, 10) works");
                pass_count++;
            end else begin
                $display("T4: FAIL - insert: size=%0d, q[0]=%0d, q[1]=%0d",
                    q.size(), q[0], q[1]);
            end
        end

        // Test 5: Insert at end (same as push_back)
        begin
            int q[$];
            q.push_back(10);
            q.push_back(20);
            q.insert(2, 30);
            if (q.size() == 3 && q[2] == 30) begin
                $display("T5: PASS - insert at end works");
                pass_count++;
            end else begin
                $display("T5: FAIL - insert at end: size=%0d, q[2]=%0d", q.size(), q[2]);
            end
        end

        // Test 6: Delete specific index
        begin
            int q[$];
            q.push_back(10);
            q.push_back(20);
            q.push_back(30);
            q.delete(1);
            if (q.size() == 2 && q[0] == 10 && q[1] == 30) begin
                $display("T6: PASS - delete(1) works");
                pass_count++;
            end else begin
                $display("T6: FAIL - delete: size=%0d, q[0]=%0d, q[1]=%0d",
                    q.size(), q[0], q[1]);
            end
        end

        // Test 7: Queue of strings
        begin
            string q[$];
            q.push_back("hello");
            q.push_back("world");
            if (q.size() == 2 && q[0] == "hello" && q[1] == "world") begin
                $display("T7: PASS - string queue works");
                pass_count++;
            end else begin
                $display("T7: FAIL - string queue: size=%0d", q.size());
            end
        end

        // Test 8: Queue push_front
        begin
            int q[$];
            q.push_back(20);
            q.push_back(30);
            q.push_front(10);
            if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
                $display("T8: PASS - push_front works");
                pass_count++;
            end else begin
                $display("T8: FAIL - push_front: size=%0d, q[0]=%0d", q.size(), q[0]);
            end
        end

        // Test 9: Queue delete all
        begin
            int q[$];
            q.push_back(10);
            q.push_back(20);
            q.push_back(30);
            q.delete();
            if (q.size() == 0) begin
                $display("T9: PASS - delete() clears queue");
                pass_count++;
            end else begin
                $display("T9: FAIL - delete(): size=%0d (expected 0)", q.size());
            end
        end

        // Test 10: Insert in middle
        begin
            int q[$];
            q.push_back(10);
            q.push_back(30);
            q.insert(1, 20);
            if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
                $display("T10: PASS - insert in middle works");
                pass_count++;
            end else begin
                $display("T10: FAIL - insert middle: %0d,%0d,%0d", q[0], q[1], q[2]);
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 10)
            $display("PASS: test_queue_methods_edge_cases");
        else
            $display("FAIL: test_queue_methods_edge_cases (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
