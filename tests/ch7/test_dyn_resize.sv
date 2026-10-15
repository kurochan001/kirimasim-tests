/*
:name: test_dyn_resize
:description: Dynamic Array Resize Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.5.1 7.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_resize.expected
*/
// IEEE 1800-2023 Section 7.5 - Dynamic Array Resize Tests
module test_dyn_resize;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int darr[];

        $display("=== IEEE 1800-2023 Dynamic Array Resize Tests ===");

        // Test 1-8: Resize tests
        $display("Test 1: Create");
        darr = new[3];
        if (darr.size() == 3) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", darr.size()); fail_count++; end

        $display("Test 2: Assign");
        darr[0] = 10;
        darr[1] = 20;
        darr[2] = 30;
        if (darr[1] == 20) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Resize larger");
        darr = new[5](darr);
        if (darr.size() == 5 && darr[0] == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Resize smaller");
        darr = new[2](darr);
        if (darr.size() == 2 && darr[1] == 20) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Delete");
        darr.delete();
        if (darr.size() == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", darr.size()); fail_count++; end

        $display("Test 6: Re-create");
        darr = new[4];
        if (darr.size() == 4) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Fill");
        darr[0] = 1;
        darr[1] = 2;
        darr[2] = 3;
        darr[3] = 4;
        if (darr.sum() == 10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", darr.sum()); fail_count++; end

        $display("Test 8: Size 1");
        darr = new[1];
        darr[0] = 99;
        if (darr.size() == 1 && darr[0] == 99) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
