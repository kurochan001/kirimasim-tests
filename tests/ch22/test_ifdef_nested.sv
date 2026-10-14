/*
:name: test_ifdef_nested
:description: Conditional compilation directives
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ifdef_nested.expected
*/
// IEEE 1800-2023 §22.6: Conditional compilation directives
// Tests nested `ifdef, `ifndef, `elsif, `else, `endif
// Verifies correct conditional compilation behavior

`define FEATURE_A
`define FEATURE_B
// FEATURE_C is not defined

module test_ifdef_nested;
    int pass_count = 0;
    int fail_count = 0;

    // Test variables set by conditional compilation
    int test1_value;
    int test2_value;
    int test3_value;
    int test4_value;

    initial begin
        $display("=== IEEE 1800-2023 §22.6: Nested Conditional Compilation ===");

        // Test 1: Simple ifdef (FEATURE_A is defined)
        `ifdef FEATURE_A
            test1_value = 1;
        `else
            test1_value = 0;
        `endif

        if (test1_value == 1) begin
            $display("PASS: ifdef FEATURE_A correctly selected");
            pass_count++;
        end else begin
            $display("FAIL: ifdef FEATURE_A failed");
            fail_count++;
        end

        // Test 2: ifndef (FEATURE_C is not defined)
        `ifndef FEATURE_C
            test2_value = 1;
        `else
            test2_value = 0;
        `endif

        if (test2_value == 1) begin
            $display("PASS: ifndef FEATURE_C correctly selected");
            pass_count++;
        end else begin
            $display("FAIL: ifndef FEATURE_C failed");
            fail_count++;
        end

        // Test 3: Nested ifdef
        `ifdef FEATURE_A
            `ifdef FEATURE_B
                test3_value = 3; // Both A and B defined
            `else
                test3_value = 2; // Only A defined
            `endif
        `else
            `ifdef FEATURE_B
                test3_value = 1; // Only B defined
            `else
                test3_value = 0; // Neither defined
            `endif
        `endif

        if (test3_value == 3) begin
            $display("PASS: Nested ifdef (A and B) correctly selected");
            pass_count++;
        end else begin
            $display("FAIL: Nested ifdef expected 3, got %0d", test3_value);
            fail_count++;
        end

        // Test 4: elsif chain
        `ifdef FEATURE_C
            test4_value = 3;
        `elsif FEATURE_B
            test4_value = 2;
        `elsif FEATURE_A
            test4_value = 1;
        `else
            test4_value = 0;
        `endif

        if (test4_value == 2) begin
            $display("PASS: elsif chain correctly selected FEATURE_B");
            pass_count++;
        end else begin
            $display("FAIL: elsif chain expected 2, got %0d", test4_value);
            fail_count++;
        end

        // Test 5: Undefined macro with ifdef
        `ifdef UNDEFINED_MACRO
            $display("FAIL: UNDEFINED_MACRO should not be defined");
            fail_count++;
        `else
            $display("PASS: UNDEFINED_MACRO correctly not defined");
            pass_count++;
        `endif

        // Test 6: Complex nested condition
        `ifdef FEATURE_A
            `ifndef FEATURE_C
                `ifdef FEATURE_B
                    $display("PASS: Complex nested condition (A && !C && B)");
                    pass_count++;
                `else
                    $display("FAIL: Complex nested condition failed at B");
                    fail_count++;
                `endif
            `else
                $display("FAIL: Complex nested condition failed at C");
                fail_count++;
            `endif
        `else
            $display("FAIL: Complex nested condition failed at A");
            fail_count++;
        `endif

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
