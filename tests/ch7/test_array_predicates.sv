/*
:name: test_array_predicates
:description: Array Methods Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.5 7.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_predicates.expected
*/
// IEEE 1800-2023 Section 7.12 - Array Methods Tests
// Tests: size, delete, insert, push/pop for dynamic arrays and queues

module test_array_predicates;
    int pass_count = 0;
    int fail_count = 0;

    int dyn_arr[];
    int queue_arr[$];
    int val;

    initial begin
        $display("=== IEEE 1800-2023 Array Methods Tests ===");

        // Test 1: Dynamic array size
        $display("Test 1: Dynamic array size");
        dyn_arr = new[5];
        if (dyn_arr.size() == 5) begin
            $display("Test 1 PASS: size=%0d", dyn_arr.size());
            pass_count++;
        end else begin
            $display("Test 1 FAIL: size=%0d", dyn_arr.size());
            fail_count++;
        end

        // Test 2: Dynamic array initialization
        $display("Test 2: Dynamic array initialization");
        dyn_arr = '{10, 20, 30, 40, 50};
        if (dyn_arr[0] == 10 && dyn_arr[4] == 50) begin
            $display("Test 2 PASS: arr[0]=%0d arr[4]=%0d", dyn_arr[0], dyn_arr[4]);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Dynamic array resize
        $display("Test 3: Dynamic array resize");
        dyn_arr = new[10](dyn_arr);  // Resize preserving values
        if (dyn_arr.size() == 10 && dyn_arr[0] == 10) begin
            $display("Test 3 PASS: new size=%0d", dyn_arr.size());
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Queue push_back
        $display("Test 4: Queue push_back");
        queue_arr = {};
        queue_arr.push_back(100);
        queue_arr.push_back(200);
        queue_arr.push_back(300);
        if (queue_arr.size() == 3) begin
            $display("Test 4 PASS: queue size=%0d", queue_arr.size());
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Queue pop_front
        $display("Test 5: Queue pop_front");
        val = queue_arr.pop_front();
        if (val == 100 && queue_arr.size() == 2) begin
            $display("Test 5 PASS: popped=%0d remaining=%0d", val, queue_arr.size());
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Queue push_front
        $display("Test 6: Queue push_front");
        queue_arr.push_front(50);
        if (queue_arr[0] == 50) begin
            $display("Test 6 PASS: front=%0d", queue_arr[0]);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Queue pop_back
        $display("Test 7: Queue pop_back");
        val = queue_arr.pop_back();
        if (val == 300) begin
            $display("Test 7 PASS: popped=%0d", val);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: val=%0d", val);
            fail_count++;
        end

        // Test 8: Delete dynamic array
        $display("Test 8: Delete dynamic array");
        dyn_arr.delete();
        if (dyn_arr.size() == 0) begin
            $display("Test 8 PASS: size after delete=%0d", dyn_arr.size());
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
