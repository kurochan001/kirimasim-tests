/*
:name: test_sys_display
:description: System Display Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sys_display.expected
*/
// IEEE 1800-2023 Section 21.2 - System Display Tests
module test_sys_display;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int val;
        string s;

        $display("=== IEEE 1800-2023 System Display Tests ===");

        $display("Test 1: Integer");
        val = 42;
        if (val == 42) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", val); fail_count++; end

        $display("Test 2: Negative");
        val = -10;
        if (val == -10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", val); fail_count++; end

        $display("Test 3: Zero");
        val = 0;
        if (val == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", val); fail_count++; end

        $display("Test 4: Large");
        val = 1000000;
        if (val == 1000000) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", val); fail_count++; end

        $display("Test 5: String");
        s = "hello";
        if (s == "hello") begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Expression");
        val = 5 + 3;
        if (val == 8) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", val); fail_count++; end

        $display("Test 7: Multiple");
        val = 100;
        if (val == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Binary format");
        val = 15;
        if (val == 4'b1111) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %b", val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
