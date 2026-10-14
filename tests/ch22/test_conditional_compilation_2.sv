/*
:name: test_conditional_compilation_2
:description: Conditional Compilation Tests
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_compilation_2.expected
*/
// IEEE 1800-2023 Section 22 - Conditional Compilation Tests
// Tests: `ifdef, `ifndef, `else, `endif, `define

`define ENABLE_FEATURE1
`define WIDTH 8
`define VERSION 2

module test_conditional_compilation;
    int pass_count = 0;
    int fail_count = 0;

    // Use defined width
    logic [`WIDTH-1:0] data;

    initial begin
        $display("=== IEEE 1800-2023 Conditional Compilation Test ===");

        // Test 1: Defined macro
        $display("Test 1: Defined macro WIDTH");
        data = 8'hAB;
        $display("  WIDTH=%0d, data=%h", `WIDTH, data);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: ifdef check
        $display("Test 2: ifdef ENABLE_FEATURE1");
        `ifdef ENABLE_FEATURE1
            $display("  ENABLE_FEATURE1 is defined");
            $display("Test 2 PASS");
            pass_count++;
        `else
            $display("Test 2 FAIL: ENABLE_FEATURE1 should be defined");
            fail_count++;
        `endif

        // Test 3: ifndef check
        $display("Test 3: ifndef UNDEFINED_MACRO");
        `ifndef UNDEFINED_MACRO
            $display("  UNDEFINED_MACRO is not defined (correct)");
            $display("Test 3 PASS");
            pass_count++;
        `else
            $display("Test 3 FAIL");
            fail_count++;
        `endif

        // Test 4: Version macro value
        $display("Test 4: Version macro");
        $display("  VERSION=%0d", `VERSION);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Nested ifdef
        $display("Test 5: Nested ifdef");
        `ifdef ENABLE_FEATURE1
            `ifdef WIDTH
                $display("  Both ENABLE_FEATURE1 and WIDTH are defined");
                $display("Test 5 PASS");
                pass_count++;
            `else
                $display("Test 5 FAIL");
                fail_count++;
            `endif
        `endif

        // Test 6: Data with macro width
        $display("Test 6: Data with macro width");
        data = {`WIDTH{1'b1}};
        $display("  data with all 1s=%h", data);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Multiple value assignments
        $display("Test 7: Multiple value assignments");
        for (int i = 0; i < 4; i++) begin
            data = i * 16;
            $display("  iter %0d: data=%h", i, data);
        end
        $display("Test 7 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
