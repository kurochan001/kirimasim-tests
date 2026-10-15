/*
:name: test_array_reduction_product
:description: Array reduction method - product()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_product.expected
*/
// IEEE 1800-2023 §7.12.3: Array reduction method - product()
module test_array_reduction_product;
    int arr[4] = '{2, 3, 4, 5};
    int dyn[];
    int q[$];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int result;

        result = arr.product();
        if (result == 120) begin $display("Test 1 PASS: product=%0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: expected 120, got %0d", result); fail_count++; end

        // Test 2: Dynamic array product
        dyn = new[3];
        dyn[0] = 2; dyn[1] = 5; dyn[2] = 7;
        result = dyn.product();
        if (result == 70) begin $display("Test 2 PASS: product=%0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: expected 70, got %0d", result); fail_count++; end

        // Test 3: Queue product
        q = '{3, 4, 5};
        result = q.product();
        if (result == 60) begin $display("Test 3 PASS: product=%0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: expected 60, got %0d", result); fail_count++; end

        // Test 4: Product with zero
        dyn = '{5, 0, 10};
        result = dyn.product();
        if (result == 0) begin $display("Test 4 PASS: product with zero=%0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: expected 0, got %0d", result); fail_count++; end

        // Test 5: Single element
        dyn = '{42};
        result = dyn.product();
        if (result == 42) begin $display("Test 5 PASS: single=%0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: expected 42, got %0d", result); fail_count++; end

        $display("Passed: %0d/5", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
