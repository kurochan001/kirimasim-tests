/*
:name: test_value_unpacked
:description: Test for unpacked array value operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.6 11.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_unpacked.expected
*/
// Test for unpacked array value operations
// IEEE 1800-2023 §7.4: Unpacked arrays
module test_value_unpacked;
    int fails = 0;

    initial begin
        int arr1[4];
        int arr2[4];
        int result;

        // Initialize
        arr1 = '{10, 20, 30, 40};

        // Element access
        if (arr1[0] != 10) begin fails++; $display("FAIL: Element 0"); end
        if (arr1[3] != 40) begin fails++; $display("FAIL: Element 3"); end

        // Array copy
        arr2 = arr1;
        arr2[0] = 100;
        if (arr1[0] != 10) begin fails++; $display("FAIL: Copy independence"); end

        // Array comparison
        arr1 = '{1, 2, 3, 4};
        arr2 = '{1, 2, 3, 4};
        if (arr1 != arr2) begin fails++; $display("FAIL: Array compare equal"); end

        arr2[2] = 99;
        if (arr1 == arr2) begin fails++; $display("FAIL: Array compare not equal"); end

        // Sum of array
        result = 0;
        foreach (arr1[i]) result += arr1[i];
        if (result != 10) begin fails++; $display("FAIL: Sum %0d", result); end

        if (fails == 0) $display("PASS: Unpacked array operations");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
