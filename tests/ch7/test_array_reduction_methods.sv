/*
:name: test_array_reduction_methods
:description: 7.12.3 Array Reduction and Locator Methods Test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3 7.12.1 7.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_methods.expected
*/
// IEEE 1800-2023 Section 7.12.2-7.12.3 Array Reduction and Locator Methods Test
// Tests size(), sum(), product(), min(), max() methods on dynamic arrays

module test_array_reduction_methods;
    int arr[];
    int sum_val;
    int prod_val;
    int size_val;
    int min_arr[$];
    int max_arr[$];
    int errors = 0;

    initial begin
        // Initialize dynamic array
        arr = new[5];
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        arr[4] = 50;

        // Test size() - IEEE 1800-2023 §7.12.2
        size_val = arr.size();
        if (size_val != 5) begin
            $display("FAIL: size() = %0d, expected 5", size_val);
            errors++;
        end else begin
            $display("PASS: size() = %0d", size_val);
        end

        // Test sum() - IEEE 1800-2023 §7.12.2
        sum_val = arr.sum();
        if (sum_val != 150) begin
            $display("FAIL: sum() = %0d, expected 150", sum_val);
            errors++;
        end else begin
            $display("PASS: sum() = %0d", sum_val);
        end

        // Test product() - IEEE 1800-2023 §7.12.2
        prod_val = arr.product();
        if (prod_val != 12000000) begin
            $display("FAIL: product() = %0d, expected 12000000", prod_val);
            errors++;
        end else begin
            $display("PASS: product() = %0d", prod_val);
        end

        // Test min() - IEEE 1800-2023 §7.12.3
        min_arr = arr.min();
        if (min_arr.size() == 0) begin
            $display("FAIL: min() returned empty queue");
            errors++;
        end else if (min_arr[0] != 10) begin
            $display("FAIL: min() = %0d, expected 10", min_arr[0]);
            errors++;
        end else begin
            $display("PASS: min() = %0d", min_arr[0]);
        end

        // Test max() - IEEE 1800-2023 §7.12.3
        max_arr = arr.max();
        if (max_arr.size() == 0) begin
            $display("FAIL: max() returned empty queue");
            errors++;
        end else if (max_arr[0] != 50) begin
            $display("FAIL: max() = %0d, expected 50", max_arr[0]);
            errors++;
        end else begin
            $display("PASS: max() = %0d", max_arr[0]);
        end

        // Summary
        if (errors == 0) begin
            $display("TEST PASSED: All array reduction methods work correctly");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end

        $finish;
    end
endmodule
