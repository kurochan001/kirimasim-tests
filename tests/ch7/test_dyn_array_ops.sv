/*
:name: test_dyn_array_ops
:description: Dynamic Array Operations Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_ops.expected
*/
// IEEE 1800-2023 Section 7.5 - Dynamic Array Operations Tests
module test_dyn_array_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int da[];
        int val;

        $display("=== IEEE 1800-2023 Dynamic Array Operations Tests ===");

        // Test 1: New with size
        $display("Test 1: New size");
        da = new[5];
        if (da.size() == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", da.size()); fail_count++; end

        // Test 2: Initialize
        $display("Test 2: Initialize");
        for (int i = 0; i < 5; i++) da[i] = i * 10;
        if (da[2] == 20) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", da[2]); fail_count++; end

        // Test 3: Resize larger
        $display("Test 3: Resize larger");
        da = new[10](da);
        if (da.size() == 10 && da[2] == 20) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: size=%0d val=%0d", da.size(), da[2]); fail_count++; end

        // Test 4: New elements init
        $display("Test 4: New init");
        if (da[7] == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", da[7]); fail_count++; end

        // Test 5: Delete
        $display("Test 5: Delete");
        da.delete();
        if (da.size() == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", da.size()); fail_count++; end

        // Test 6: Reinitialize
        $display("Test 6: Reinit");
        da = new[3];
        da[0] = 100;
        da[1] = 200;
        da[2] = 300;
        if (da[1] == 200) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", da[1]); fail_count++; end

        // Test 7: First element
        $display("Test 7: First");
        if (da[0] == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", da[0]); fail_count++; end

        // Test 8: Last element
        $display("Test 8: Last");
        if (da[da.size()-1] == 300) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", da[da.size()-1]); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
