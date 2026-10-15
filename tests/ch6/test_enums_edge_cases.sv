/*
:name: test_enums_edge_cases
:description: Test: Enums edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enums_edge_cases.expected
*/
// Test: Enums edge cases
// IEEE 1800-2023 Section 6.19 Enumerated Types
// Tests corner cases: enum values, methods, casting

`timescale 1ns/1ps

module test_enums_edge_cases;
    int passed = 0;
    int failed = 0;

    typedef enum {RED, GREEN, BLUE} color_t;
    typedef enum logic [2:0] {IDLE=0, RUN=3, STOP=7} state_t;
    typedef enum int {NEG=-1, ZERO=0, POS=1} signed_enum_t;

    initial begin
        $display("TEST: Enums edge cases");

        // Test 1: Default enum values (0, 1, 2)
        begin
            if (RED == 0 && GREEN == 1 && BLUE == 2) begin
                $display("  [PASS] Default enum values");
                passed++;
            end else begin
                $display("  [FAIL] Default values");
                failed++;
            end
        end

        // Test 2: Explicit enum values
        begin
            if (IDLE == 0 && RUN == 3 && STOP == 7) begin
                $display("  [PASS] Explicit enum values");
                passed++;
            end else begin
                $display("  [FAIL] Explicit values");
                failed++;
            end
        end

        // Test 3: Enum variable assignment
        begin
            static color_t c = GREEN;
            if (c == GREEN) begin
                $display("  [PASS] Enum variable assignment");
                passed++;
            end else begin
                $display("  [FAIL] Assignment");
                failed++;
            end
        end

        // Test 4: Enum comparison
        begin
            static color_t c1 = RED;
            static color_t c2 = RED;
            static color_t c3 = BLUE;
            if (c1 == c2 && c1 != c3) begin
                $display("  [PASS] Enum comparison");
                passed++;
            end else begin
                $display("  [FAIL] Comparison");
                failed++;
            end
        end

        // Test 5: Enum to int cast
        begin
            static color_t c = BLUE;
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = int'(c);
            if (val == 2) begin
                $display("  [PASS] Enum to int cast");
                passed++;
            end else begin
                $display("  [FAIL] Cast: %0d", val);
                failed++;
            end
        end

        // Test 6: Enum name method
        begin
            static color_t c = GREEN;
            if (c.name() == "GREEN") begin
                $display("  [PASS] Enum name() method");
                passed++;
            end else begin
                $display("  [FAIL] Name: %s", c.name());
                failed++;
            end
        end

        // Test 7: Enum first method
        begin
            color_t c;
            c = c.first();
            if (c == RED) begin
                $display("  [PASS] Enum first() method");
                passed++;
            end else begin
                $display("  [FAIL] First");
                failed++;
            end
        end

        // Test 8: Enum next method
        begin
            static color_t c = RED;
            c = c.next();
            if (c == GREEN) begin
                $display("  [PASS] Enum next() method");
                passed++;
            end else begin
                $display("  [FAIL] Next");
                failed++;
            end
        end

        // Test 9: Enum with signed values
        begin
            if (NEG == -1 && ZERO == 0 && POS == 1) begin
                $display("  [PASS] Signed enum values");
                passed++;
            end else begin
                $display("  [FAIL] Signed enum");
                failed++;
            end
        end

        // Test 10: Enum in case statement
        begin
            static color_t c = BLUE;
            static int result = 0;
            case (c)
                RED: result = 1;
                GREEN: result = 2;
                BLUE: result = 3;
            endcase
            if (result == 3) begin
                $display("  [PASS] Enum in case");
                passed++;
            end else begin
                $display("  [FAIL] Case: %0d", result);
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
