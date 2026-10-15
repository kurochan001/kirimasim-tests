/*
:name: test_operator_edge_cases_2
:description: Overflow, signed comparison, case and wildcard equality, replication and power rules
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.5 11.4.6 11.4.12
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_edge_cases_2.expected
*/
// Overflow, signed comparison, case and wildcard equality, replication and power rules
// IEEE 1800-2023 Chapter 11 Operators
// Tests corner cases: overflow, signed/unsigned, wildcards, streaming

`timescale 1ns/1ps

module test_operator_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Operator edge cases");

        // Test 1: Integer overflow behavior
        begin
            static int max_int = 32'h7FFFFFFF;
            static int overflow;
            // Assigned here so the result does not depend on the order of static initializers.
            overflow = max_int + 1;
            // Expected: wraps to negative
            if (overflow < 0) begin
                $display("  [PASS] Integer overflow wraps to negative");
                passed++;
            end else begin
                $display("  [FAIL] Integer overflow should wrap");
                failed++;
            end
        end

        // Test 2: Unsigned vs signed comparison
        begin
            static logic signed [7:0] s_val = -1;  // 8'hFF
            static logic [7:0] u_val = 8'hFE;
            // When comparing signed to unsigned, result depends on context
            if ($signed(s_val) < 0) begin
                $display("  [PASS] Signed -1 is negative");
                passed++;
            end else begin
                $display("  [FAIL] Signed -1 should be negative");
                failed++;
            end
        end

        // Test 3: Case equality with X
        begin
            static logic [3:0] val3 = 4'bx01x;
            // === compares X as value, not wildcard
            if (val3 === 4'bx01x) begin
                $display("  [PASS] Case equality matches X");
                passed++;
            end else begin
                $display("  [FAIL] Case equality should match X");
                failed++;
            end
        end

        // Test 4: Wildcard equality
        // x and z bits of the right operand match any value (11.4.6).
        begin
            static logic [3:0] val4 = 4'b1010;
            if ((val4 ==? 4'b1x1z) === 1'b1 && (val4 ==? 4'b0x1x) === 1'b0) begin
                $display("  [PASS] Wildcard equality");
                passed++;
            end else begin
                $display("  [FAIL] Wildcard equality");
                failed++;
            end
        end

        // Test 5: Replication operator
        begin
            static logic [7:0] rep = {4{2'b11}};  // 8'b11111111
            if (rep == 8'hFF) begin
                $display("  [PASS] Replication {4{2'b11}} = 8'hFF");
                passed++;
            end else begin
                $display("  [FAIL] Replication should produce 8'hFF");
                failed++;
            end
        end

        // Test 6: Concatenation with different widths
        begin
            static logic [3:0] a = 4'hA;
            static logic [3:0] b = 4'hB;
            static logic [7:0] concat;
            // Assigned here so the result does not depend on the order of static initializers.
            concat = {a, b};
            if (concat == 8'hAB) begin
                $display("  [PASS] Concatenation {A,B} = AB");
                passed++;
            end else begin
                $display("  [FAIL] Concatenation should produce AB");
                failed++;
            end
        end

        // Test 7: Shift with zero amount
        begin
            static logic [7:0] val7 = 8'hAB;
            if ((val7 << 0) == 8'hAB && (val7 >> 0) == 8'hAB) begin
                $display("  [PASS] Shift by 0 is identity");
                passed++;
            end else begin
                $display("  [FAIL] Shift by 0 should be identity");
                failed++;
            end
        end

        // Test 8: Bitwise XOR self
        begin
            static logic [7:0] val8 = 8'hAB;
            if ((val8 ^ val8) == 8'h00) begin
                $display("  [PASS] XOR with self = 0");
                passed++;
            end else begin
                $display("  [FAIL] XOR with self should be 0");
                failed++;
            end
        end

        // Test 9: Unary minus on zero
        begin
            static int val9 = 0;
            static int neg;
            // Assigned here so the result does not depend on the order of static initializers.
            neg = -val9;
            if (neg == 0) begin
                $display("  [PASS] -0 = 0");
                passed++;
            end else begin
                $display("  [FAIL] -0 should be 0");
                failed++;
            end
        end

        // Test 10: Power of 1
        begin
            static int base = 999;
            if ((base ** 1) == 999 && (1 ** base) == 1) begin
                $display("  [PASS] Power rules: x**1=x, 1**x=1");
                passed++;
            end else begin
                $display("  [FAIL] Power rules should work");
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
