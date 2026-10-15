/*
:name: test_module_inst
:description: Module Instantiation Tests
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_inst.expected
*/
// IEEE 1800-2023 Section 23 - Module Instantiation Tests
module sub_module(input int a, output int b);
    assign b = a * 2;
endmodule

module test_module_inst;
    int pass_count = 0;
    int fail_count = 0;
    int in_val, out_val;

    sub_module u1(.a(in_val), .b(out_val));

    initial begin
        $display("=== IEEE 1800-2023 Module Instantiation Tests ===");

        // Test 1: Basic instantiation
        $display("Test 1: Basic inst");
        in_val = 5;
        #1;
        if (out_val == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", out_val); fail_count++; end

        // Test 2: Change input
        $display("Test 2: Change input");
        in_val = 10;
        #1;
        if (out_val == 20) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", out_val); fail_count++; end

        // Test 3: Zero input
        $display("Test 3: Zero input");
        in_val = 0;
        #1;
        if (out_val == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", out_val); fail_count++; end

        // Test 4: Negative input
        $display("Test 4: Negative");
        in_val = -3;
        #1;
        if (out_val == -6) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", out_val); fail_count++; end

        // Test 5: Large value
        $display("Test 5: Large");
        in_val = 1000;
        #1;
        if (out_val == 2000) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", out_val); fail_count++; end

        // Test 6: One
        $display("Test 6: One");
        in_val = 1;
        #1;
        if (out_val == 2) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", out_val); fail_count++; end

        // Test 7: Sequential
        $display("Test 7: Sequential");
        in_val = 7;
        #1;
        in_val = 8;
        #1;
        if (out_val == 16) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", out_val); fail_count++; end

        // Test 8: Final
        $display("Test 8: Final");
        in_val = 50;
        #1;
        if (out_val == 100) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", out_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
