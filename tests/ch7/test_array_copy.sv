/*
:name: test_array_copy
:description: Array Copy Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_copy.expected
*/
// IEEE 1800-2023 Section 7.4 - Array Copy Tests
module test_array_copy;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        static int arr1[4] = '{1, 2, 3, 4};
        int arr2[4];
        int i;

        $display("=== IEEE 1800-2023 Array Copy Tests ===");

        $display("Test 1: Init");
        if (arr1[0] == 1 && arr1[3] == 4) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Manual copy");
        for (i = 0; i < 4; i++) arr2[i] = arr1[i];
        if (arr2[0] == 1 && arr2[3] == 4) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Modify arr2");
        arr2[0] = 100;
        if (arr2[0] == 100) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", arr2[0]); fail_count++; end

        $display("Test 4: arr1 unchanged");
        if (arr1[0] == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", arr1[0]); fail_count++; end

        $display("Test 5: arr1 sum");
        if (arr1.sum() == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", arr1.sum()); fail_count++; end

        $display("Test 6: arr2 element");
        if (arr2[1] == 2) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", arr2[1]); fail_count++; end

        $display("Test 7: Modify arr1");
        arr1[3] = 40;
        if (arr1[3] == 40) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", arr1[3]); fail_count++; end

        $display("Test 8: arr2 still 4");
        if (arr2[3] == 4) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", arr2[3]); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
