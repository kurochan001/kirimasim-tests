/*
:name: test_array_reduction_with_clause
:description: Array Reduction Methods with with-clause
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3 7.12.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_with_clause.expected
*/
// IEEE 1800-2023 §7.12.2 Array Reduction Methods with with-clause
// Tests sum, product, and, or, xor with with-clause

module test_array_reduction_with_clause;
    int arr[] = '{1, 2, 3, 4, 5};
    int result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: sum with with-clause (double each element)
        result = arr.sum(x) with (x * 2);
        if (result == 30) begin  // (1+2+3+4+5)*2 = 30
            $display("PASS: sum with (x * 2) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: sum with (x * 2) = %0d, expected 30", result);
            fail_count++;
        end

        // Test 2: sum with with-clause using item.index
        result = arr.sum() with (item.index);
        if (result == 10) begin  // 0+1+2+3+4 = 10
            $display("PASS: sum with (item.index) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: sum with (item.index) = %0d, expected 10", result);
            fail_count++;
        end

        // Test 3: product with with-clause
        result = arr.product(x) with (x);
        if (result == 120) begin  // 1*2*3*4*5 = 120
            $display("PASS: product with (x) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: product with (x) = %0d, expected 120", result);
            fail_count++;
        end

        // Test 4: sum of squares
        result = arr.sum(x) with (x * x);
        if (result == 55) begin  // 1+4+9+16+25 = 55
            $display("PASS: sum with (x * x) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: sum with (x * x) = %0d, expected 55", result);
            fail_count++;
        end

        // Test 5: sum with conditional
        result = arr.sum(x) with (x > 2 ? x : 0);
        if (result == 12) begin  // 0+0+3+4+5 = 12
            $display("PASS: sum with (x > 2 ? x : 0) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: sum with (x > 2 ? x : 0) = %0d, expected 12", result);
            fail_count++;
        end

        // Test 6: simple sum without with-clause
        result = arr.sum();
        if (result == 15) begin  // 1+2+3+4+5 = 15
            $display("PASS: simple sum() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: simple sum() = %0d, expected 15", result);
            fail_count++;
        end

        // Test 7: simple product without with-clause
        result = arr.product();
        if (result == 120) begin  // 1*2*3*4*5 = 120
            $display("PASS: simple product() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: simple product() = %0d, expected 120", result);
            fail_count++;
        end

        $display("");
        $display("=== Array Reduction with With-Clause Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
