/*
:name: test_dynamic_array_queue_size
:description: Sizes of a dynamic array and a queue after new[], resizing, push_back and delete
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5.2 7.5.3 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_queue_size.expected
*/
// IEEE 1800-2023 §7.5

module test_dynamic_array_queue_size;
    int dyn_arr[];
    int queue_arr[$];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Dynamic array creation
        test_count++;
        dyn_arr = new[5];
        if (dyn_arr.size() == 5) begin
            $display("Test 1: Dynamic array creation PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Array resize
        test_count++;
        dyn_arr = new[10](dyn_arr);
        if (dyn_arr.size() == 10) begin
            $display("Test 2: Array resize PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Queue operations
        test_count++;
        queue_arr.push_back(1);
        queue_arr.push_back(2);
        queue_arr.push_back(3);
        if (queue_arr.size() == 3) begin
            $display("Test 3: Queue operations PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Array delete
        test_count++;
        dyn_arr.delete();
        if (dyn_arr.size() == 0) begin
            $display("Test 4: Array delete PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Queue clear
        test_count++;
        queue_arr.delete();
        if (queue_arr.size() == 0) begin
            $display("Test 5: Queue clear PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
