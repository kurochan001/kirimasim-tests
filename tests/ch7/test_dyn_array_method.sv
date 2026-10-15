/*
:name: test_dyn_array_method
:description: Dynamic Array Method Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5.2 7.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_method.expected
*/
// IEEE 1800-2023 Section 7.5 - Dynamic Array Method Tests
module test_dyn_array_method;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int dyn[];
        int i;

        $display("=== IEEE 1800-2023 Dynamic Array Method Tests ===");

        $display("Test 1: Empty size");
        if (dyn.size() == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", dyn.size()); fail_count++; end

        $display("Test 2: New array");
        dyn = new[5];
        if (dyn.size() == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", dyn.size()); fail_count++; end

        $display("Test 3: Fill array");
        for (i = 0; i < 5; i++) dyn[i] = i * 10;
        if (dyn[0] == 0 && dyn[4] == 40) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Resize larger");
        dyn = new[8](dyn);
        if (dyn.size() == 8 && dyn[4] == 40) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: size=%0d, dyn[4]=%0d", dyn.size(), dyn[4]); fail_count++; end

        $display("Test 5: Fill new");
        dyn[5] = 50;
        dyn[6] = 60;
        dyn[7] = 70;
        if (dyn[7] == 70) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", dyn[7]); fail_count++; end

        $display("Test 6: Delete");
        dyn.delete();
        if (dyn.size() == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", dyn.size()); fail_count++; end

        $display("Test 7: Recreate");
        dyn = new[3];
        dyn[0] = 100;
        dyn[1] = 200;
        dyn[2] = 300;
        if (dyn[1] == 200) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", dyn[1]); fail_count++; end

        $display("Test 8: Final size");
        if (dyn.size() == 3) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", dyn.size()); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
