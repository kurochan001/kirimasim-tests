/*
:name: test_value_dynamic
:description: Test for dynamic array value operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.5.1 7.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_dynamic.expected
*/
// Test for dynamic array value operations
// IEEE 1800-2023 §7.5: Dynamic arrays
module test_value_dynamic;
    int fails = 0;

    initial begin
        int da[];
        int da2[];
        int sum;

        // Create
        da = new[5];
        if (da.size() != 5) begin fails++; $display("FAIL: Initial size"); end

        // Initialize
        foreach (da[i]) da[i] = i * 10;
        if (da[3] != 30) begin fails++; $display("FAIL: Initialize"); end

        // Resize with copy
        da2 = new[da.size()](da);
        if (da2[2] != 20) begin fails++; $display("FAIL: Copy"); end

        // Resize larger
        da = new[10](da);
        if (da.size() != 10) begin fails++; $display("FAIL: Resize larger"); end
        if (da[4] != 40) begin fails++; $display("FAIL: Preserved after resize"); end

        // Resize smaller
        da = new[3](da);
        if (da.size() != 3) begin fails++; $display("FAIL: Resize smaller"); end
        if (da[2] != 20) begin fails++; $display("FAIL: Truncated"); end

        // Delete
        da.delete();
        if (da.size() != 0) begin fails++; $display("FAIL: Delete"); end

        // Sum method
        da = new[4];
        da = '{1, 2, 3, 4};
        sum = da.sum();
        if (sum != 10) begin fails++; $display("FAIL: Sum %0d", sum); end

        if (fails == 0) $display("PASS: Dynamic array operations");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
