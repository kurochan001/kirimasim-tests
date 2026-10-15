/*
:name: test_undef
:description: `undef directive
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.2 22.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_undef.expected
*/
// IEEE 1800-2023 §22.5.2: `undef directive
// Tests macro undefined behavior
// Verifies that `undef correctly removes macro definitions

`define TEMP_MACRO 42
`define ANOTHER_MACRO 100

module test_undef;
    int pass_count = 0;
    int fail_count = 0;
    int test_value;

    initial begin
        $display("=== IEEE 1800-2023 §22.5.2: undef Directive ===");

        // Test 1: Macro is defined before undef
        `ifdef TEMP_MACRO
            $display("PASS: TEMP_MACRO is defined initially");
            pass_count++;
            test_value = `TEMP_MACRO;
            if (test_value == 42) begin
                $display("PASS: TEMP_MACRO value is 42");
                pass_count++;
            end else begin
                $display("FAIL: TEMP_MACRO value is %0d, expected 42", test_value);
                fail_count++;
            end
        `else
            $display("FAIL: TEMP_MACRO should be defined initially");
            fail_count++;
        `endif

        // Undefine TEMP_MACRO
        `undef TEMP_MACRO

        // Test 2: Macro is undefined after undef
        `ifdef TEMP_MACRO
            $display("FAIL: TEMP_MACRO should be undefined after undef");
            fail_count++;
        `else
            $display("PASS: TEMP_MACRO is correctly undefined after undef");
            pass_count++;
        `endif

        // Test 3: Another macro is still defined
        `ifdef ANOTHER_MACRO
            $display("PASS: ANOTHER_MACRO is still defined");
            pass_count++;
            test_value = `ANOTHER_MACRO;
            if (test_value == 100) begin
                $display("PASS: ANOTHER_MACRO value is 100");
                pass_count++;
            end else begin
                $display("FAIL: ANOTHER_MACRO value is %0d, expected 100", test_value);
                fail_count++;
            end
        `else
            $display("FAIL: ANOTHER_MACRO should still be defined");
            fail_count++;
        `endif

        // Test 4: Redefine the undefined macro
        `define TEMP_MACRO 99

        `ifdef TEMP_MACRO
            $display("PASS: TEMP_MACRO is redefined");
            pass_count++;
            test_value = `TEMP_MACRO;
            if (test_value == 99) begin
                $display("PASS: Redefined TEMP_MACRO value is 99");
                pass_count++;
            end else begin
                $display("FAIL: Redefined TEMP_MACRO value is %0d, expected 99", test_value);
                fail_count++;
            end
        `else
            $display("FAIL: TEMP_MACRO should be redefined");
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
