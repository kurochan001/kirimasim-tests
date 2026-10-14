/*
:name: test_queue_operations
:description: Queue Operations Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_operations.expected
*/
// IEEE 1800-2023 Section 7.10 - Queue Operations Tests
// Tests: Queue methods, push, pop, insert, delete

module test_queue_operations;
    int pass_count = 0;
    int fail_count = 0;

    int q1[$];
    int q2[$];
    int val;

    initial begin
        $display("=== IEEE 1800-2023 Queue Operations Tests ===");

        // Test 1: Push back
        $display("Test 1: Push back");
        q1.push_back(10);
        q1.push_back(20);
        q1.push_back(30);
        if (q1.size() == 3) begin
            $display("Test 1 PASS: size=%0d after push_back", q1.size());
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Pop front
        $display("Test 2: Pop front");
        val = q1.pop_front();
        if (val == 10 && q1.size() == 2) begin
            $display("Test 2 PASS: popped=%0d, size=%0d", val, q1.size());
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Pop back
        $display("Test 3: Pop back");
        val = q1.pop_back();
        if (val == 30 && q1.size() == 1) begin
            $display("Test 3 PASS: popped=%0d, size=%0d", val, q1.size());
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Push front
        $display("Test 4: Push front");
        q1.push_front(5);
        if (q1[0] == 5 && q1.size() == 2) begin
            $display("Test 4 PASS: front=%0d", q1[0]);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Index access
        $display("Test 5: Index access");
        if (q1[0] == 5 && q1[1] == 20) begin
            $display("Test 5 PASS: q1[0]=%0d, q1[1]=%0d", q1[0], q1[1]);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Delete all
        $display("Test 6: Delete all");
        q1.delete();
        if (q1.size() == 0) begin
            $display("Test 6 PASS: queue empty after delete");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Multiple push/pop
        $display("Test 7: Multiple push/pop");
        q2.push_back(1);
        q2.push_back(2);
        q2.push_back(3);
        val = q2.pop_front();
        val = q2.pop_front();
        if (val == 2 && q2.size() == 1 && q2[0] == 3) begin
            $display("Test 7 PASS: remaining=%0d", q2[0]);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Queue iteration
        $display("Test 8: Queue iteration");
        q2.delete();
        q2.push_back(100);
        q2.push_back(200);
        q2.push_back(300);
        val = 0;
        for (int i = 0; i < q2.size(); i++) begin
            val += q2[i];
        end
        if (val == 600) begin
            $display("Test 8 PASS: sum=%0d", val);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
