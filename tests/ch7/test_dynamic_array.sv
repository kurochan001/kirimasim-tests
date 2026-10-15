/*
:name: test_dynamic_array
:description: Dynamic Arrays (§7.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array.expected
*/
// IEEE 1800-2023 Dynamic Arrays (§7.5)
// Tests dynamic array operations

module test_dynamic_array;
    initial begin
        int dyn_arr[];
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Initial size is 0
        if (dyn_arr.size() == 0) begin
            $display("PASS: Initial size is 0");
            pass_count++;
        end else begin
            $display("FAIL: Initial size should be 0");
            fail_count++;
        end

        // Test 2: new() allocation
        dyn_arr = new[5];
        if (dyn_arr.size() == 5) begin
            $display("PASS: Allocated size is 5");
            pass_count++;
        end else begin
            $display("FAIL: Allocated size should be 5");
            fail_count++;
        end

        // Test 3: Set and get values
        for (int i = 0; i < 5; i++) dyn_arr[i] = i * 10;
        if (dyn_arr[0] == 0 && dyn_arr[2] == 20 && dyn_arr[4] == 40) begin
            $display("PASS: Values set correctly");
            pass_count++;
        end else begin
            $display("FAIL: Values not set correctly");
            fail_count++;
        end

        // Test 4: Resize preserving values
        dyn_arr = new[8](dyn_arr);
        if (dyn_arr.size() == 8 && dyn_arr[2] == 20) begin
            $display("PASS: Resize preserves values");
            pass_count++;
        end else begin
            $display("FAIL: Resize lost values");
            fail_count++;
        end

        // Test 5: delete()
        dyn_arr.delete();
        if (dyn_arr.size() == 0) begin
            $display("PASS: delete() clears array");
            pass_count++;
        end else begin
            $display("FAIL: delete() should clear array");
            fail_count++;
        end

        // Test 6: Array literal assignment
        dyn_arr = '{1, 2, 3, 4, 5};
        if (dyn_arr.size() == 5 && dyn_arr[0] == 1 && dyn_arr[4] == 5) begin
            $display("PASS: Literal assignment works");
            pass_count++;
        end else begin
            $display("FAIL: Literal assignment failed");
            fail_count++;
        end

        $display("");
        $display("=== Dynamic Array Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
