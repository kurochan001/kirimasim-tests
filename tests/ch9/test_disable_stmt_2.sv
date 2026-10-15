/*
:name: test_disable_stmt_2
:description: Disable Statement Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_stmt_2.expected
*/
// IEEE 1800-2023 Section 9.6 - Disable Statement Tests
module test_disable_stmt;
    int pass_count = 0;
    int fail_count = 0;
    int value;

    initial begin
        $display("=== IEEE 1800-2023 Disable Statement Tests ===");

        // Test 1: Basic disable
        $display("Test 1: Basic disable");
        value = 0;
        begin : block1
            value = 1;
            if (value == 1) disable block1;
            value = 2;
        end
        if (value == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", value); fail_count++; end

        // Test 2: Disable with condition
        $display("Test 2: Conditional");
        value = 0;
        begin : block2
            for (int i = 0; i < 10; i++) begin
                value = value + 1;
                if (value == 5) disable block2;
            end
        end
        if (value == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", value); fail_count++; end

        // Test 3: Nested blocks
        $display("Test 3: Nested");
        value = 0;
        begin : outer
            begin : inner
                value = 1;
                disable inner;
                value = 2;
            end
            value = value + 10;
        end
        if (value == 11) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", value); fail_count++; end

        // Test 4: Disable outer
        $display("Test 4: Disable outer");
        value = 0;
        begin : outer2
            begin : inner2
                value = 1;
                disable outer2;
                value = 2;
            end
            value = value + 10;
        end
        if (value == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", value); fail_count++; end

        // Test 5: No disable
        $display("Test 5: No disable");
        value = 0;
        begin : block5
            value = 5;
        end
        if (value == 5) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", value); fail_count++; end

        // Test 6: Complex condition
        $display("Test 6: Complex");
        value = 0;
        begin : block6
            value = 3;
            if (value > 0 && value < 5) disable block6;
            value = 10;
        end
        if (value == 3) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", value); fail_count++; end

        // Test 7: Loop disable
        $display("Test 7: Loop");
        value = 0;
        begin : block7
            for (int i = 0; i < 100; i++) begin
                value = i;
                if (i == 7) disable block7;
            end
        end
        if (value == 7) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", value); fail_count++; end

        // Test 8: Multiple statements
        $display("Test 8: Multiple");
        value = 0;
        begin : block8
            value = 1;
            value = value + 1;
            value = value + 1;
            disable block8;
            value = 100;
        end
        if (value == 3) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", value); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
