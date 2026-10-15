/*
:name: test_display_ops
:description: Display Operations Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_ops.expected
*/
// IEEE 1800-2023 Section 21 - Display Operations Tests
module test_display_ops;
    int pass_count = 0;
    int fail_count = 0;
    int val;

    initial begin
        string s;
        
        $display("=== IEEE 1800-2023 Display Operations Tests ===");

        // Test 1: Integer display
        $display("Test 1: Integer");
        val = 42;
        if (val == 42) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Hex display
        $display("Test 2: Hex");
        val = 255;
        if (val == 255) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Binary display
        $display("Test 3: Binary");
        val = 15;
        if (val == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: String display
        $display("Test 4: String");
        s = "hello";
        if (s == "hello") begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Multiple args
        $display("Test 5: Multi args");
        val = 100;
        if (val == 100) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Negative
        $display("Test 6: Negative");
        val = -50;
        if (val == -50) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Zero
        $display("Test 7: Zero");
        val = 0;
        if (val == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Large value
        $display("Test 8: Large");
        val = 1000000;
        if (val == 1000000) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
