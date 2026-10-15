/*
:name: test_array_init
:description: Array Initialization Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 10.9.1 20.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_init.expected
*/
// IEEE 1800-2023 Section 7.4 - Array Initialization Tests
module test_array_init;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        static int arr1[4] = '{1, 2, 3, 4};
        int arr2[3];
        int arr3[5];

        $display("=== IEEE 1800-2023 Array Init Tests ===");

        // Test 1: Explicit init
        $display("Test 1: Explicit");
        if (arr1[0] == 1 && arr1[3] == 4) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Manual init
        $display("Test 2: Manual");
        arr2[0] = 10;
        arr2[1] = 10;
        arr2[2] = 10;
        if (arr2[0] == 10 && arr2[2] == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Assign elem
        $display("Test 3: Assign");
        arr3[0] = 100;
        arr3[4] = 500;
        if (arr3[0] == 100 && arr3[4] == 500) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Sum check
        $display("Test 4: Sum");
        if (arr1.sum() == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", arr1.sum()); fail_count++; end

        // Test 5: Element access
        $display("Test 5: Access");
        if (arr1[1] == 2 && arr1[2] == 3) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Modify
        $display("Test 6: Modify");
        arr1[0] = 10;
        if (arr1[0] == 10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", arr1[0]); fail_count++; end

        // Test 7: All same
        $display("Test 7: All same");
        if (arr2[1] == 10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", arr2[1]); fail_count++; end

        // Test 8: Size check
        $display("Test 8: Size");
        if ($size(arr1) == 4) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", $size(arr1)); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
