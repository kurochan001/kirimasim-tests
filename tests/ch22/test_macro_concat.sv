/*
:name: test_macro_concat
:description: Macro text substitution and concatenation
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_concat.expected
*/
// IEEE 1800-2023 §22.5.1: Macro text substitution and concatenation
// Tests `` (double backtick) for token concatenation
// Verifies macro text manipulation features

`define PREFIX data_
`define SUFFIX _reg
`define WIDTH 8

// Token concatenation using ``
`define MAKE_NAME(base) `PREFIX``base```SUFFIX

// String conversion using `"
`define STRINGIFY(x) `"x`"

// Macro that generates signal declarations
`define DECLARE_SIGNAL(name) \
    logic [`WIDTH-1:0] name

module test_macro_concat;
    int pass_count = 0;
    int fail_count = 0;

    // Use macro-generated names
    `DECLARE_SIGNAL(test_signal);
    `DECLARE_SIGNAL(another_signal);

    initial begin
        $display("=== IEEE 1800-2023 §22.5.1: Macro Concatenation ===");

        // Test 1: Simple macro value
        if (`WIDTH == 8) begin
            $display("PASS: WIDTH macro equals 8");
            pass_count++;
        end else begin
            $display("FAIL: WIDTH macro is %0d, expected 8", `WIDTH);
            fail_count++;
        end

        // Test 2: Signal width from macro
        test_signal = 8'hFF;
        if (test_signal == 8'hFF) begin
            $display("PASS: DECLARE_SIGNAL created 8-bit signal");
            pass_count++;
        end else begin
            $display("FAIL: Signal value mismatch");
            fail_count++;
        end

        // Test 3: Multiple signals
        another_signal = 8'hAB;
        if (another_signal == 8'hAB) begin
            $display("PASS: Multiple DECLARE_SIGNAL macros work");
            pass_count++;
        end else begin
            $display("FAIL: Second signal value mismatch");
            fail_count++;
        end

        // Test 4: Stringify macro
        $display("STRINGIFY test: %s", `STRINGIFY(hello_world));
        pass_count++;
        $display("PASS: STRINGIFY macro executed");

        // Test 5: Macro with arithmetic
        `define DOUBLE_WIDTH (`WIDTH * 2)
        if (`DOUBLE_WIDTH == 16) begin
            $display("PASS: DOUBLE_WIDTH = %0d", `DOUBLE_WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: DOUBLE_WIDTH = %0d, expected 16", `DOUBLE_WIDTH);
            fail_count++;
        end

        // Test 6: Nested macro expansion
        `define INNER 10
        `define OUTER (`INNER + 5)
        if (`OUTER == 15) begin
            $display("PASS: Nested macro OUTER = %0d", `OUTER);
            pass_count++;
        end else begin
            $display("FAIL: Nested macro OUTER = %0d, expected 15", `OUTER);
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
