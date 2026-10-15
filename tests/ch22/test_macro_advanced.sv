/*
:name: test_macro_advanced
:description: Chapter 22: Compiler Directives - Advanced Macro Tests
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_advanced.expected
*/
// IEEE 1800-2023 Chapter 22: Compiler Directives - Advanced Macro Tests
// Tests: §22.3 `define with arguments, §22.4 Conditional compilation

`timescale 1ns/1ps

// §22.3: Basic macro
`define WIDTH 8
`define DEPTH 16

// §22.3.1: Macro with arguments
`define ADD(a, b) ((a) + (b))
`define MUL(a, b) ((a) * (b))
`define MAX(a, b) ((a) > (b) ? (a) : (b))
`define MIN(a, b) ((a) < (b) ? (a) : (b))

// §22.3.2: Macro with default argument
`define SHIFT_LEFT(val, amt=1) ((val) << (amt))

// §22.3.3: Stringification
`define STRINGIFY(x) `"x`"

// §22.3.4: Token pasting
`define CONCAT(a, b) a``b
`define MAKE_SIGNAL(name) logic [`WIDTH-1:0] name

// §22.4: Nested conditional compilation
`define FEATURE_A
`define FEATURE_B

module test_macro_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Test macro-defined signals
    `MAKE_SIGNAL(sig1);
    `MAKE_SIGNAL(sig2);

    // Conditional compilation
`ifdef FEATURE_A
    logic feature_a_enabled = 1;
`else
    logic feature_a_enabled = 0;
`endif

`ifndef FEATURE_C
    logic feature_c_disabled = 1;
`else
    logic feature_c_disabled = 0;
`endif

    // Nested ifdef
`ifdef FEATURE_A
    `ifdef FEATURE_B
        logic both_features = 1;
    `else
        logic both_features = 0;
    `endif
`else
    logic both_features = 0;
`endif

    // elsif chain
`ifdef MODE_A
    localparam MODE = 1;
`elsif MODE_B
    localparam MODE = 2;
`elsif FEATURE_A
    localparam MODE = 3;  // This should match
`else
    localparam MODE = 0;
`endif

    initial begin
        $display("=== IEEE 1800-2023 §22 Macro Advanced Tests ===");
        $display("");

        // Test 1: Basic macro substitution
        if (`WIDTH == 8 && `DEPTH == 16) begin
            $display("PASS: Basic macro WIDTH=%0d, DEPTH=%0d", `WIDTH, `DEPTH);
            pass_count++;
        end else begin
            $display("FAIL: Basic macro substitution");
            fail_count++;
        end

        // Test 2: Macro with arguments
        if (`ADD(10, 20) == 30) begin
            $display("PASS: ADD(10, 20) = 30");
            pass_count++;
        end else begin
            $display("FAIL: ADD macro");
            fail_count++;
        end

        if (`MUL(5, 6) == 30) begin
            $display("PASS: MUL(5, 6) = 30");
            pass_count++;
        end else begin
            $display("FAIL: MUL macro");
            fail_count++;
        end

        if (`MAX(100, 50) == 100 && `MIN(100, 50) == 50) begin
            $display("PASS: MAX/MIN macros");
            pass_count++;
        end else begin
            $display("FAIL: MAX/MIN macros");
            fail_count++;
        end

        // Test 3: Nested macro arguments
        if (`ADD(`MUL(2, 3), `MUL(4, 5)) == 26) begin
            $display("PASS: Nested macro: ADD(MUL(2,3), MUL(4,5)) = 26");
            pass_count++;
        end else begin
            $display("FAIL: Nested macro");
            fail_count++;
        end

        // Test 4: Macro with default argument
        if (`SHIFT_LEFT(1) == 2 && `SHIFT_LEFT(1, 4) == 16) begin
            $display("PASS: SHIFT_LEFT with default argument");
            pass_count++;
        end else begin
            $display("FAIL: SHIFT_LEFT with default argument");
            fail_count++;
        end

        // Test 5: ifdef/ifndef
        if (feature_a_enabled == 1) begin
            $display("PASS: ifdef FEATURE_A");
            pass_count++;
        end else begin
            $display("FAIL: ifdef FEATURE_A");
            fail_count++;
        end

        if (feature_c_disabled == 1) begin
            $display("PASS: ifndef FEATURE_C");
            pass_count++;
        end else begin
            $display("FAIL: ifndef FEATURE_C");
            fail_count++;
        end

        // Test 6: Nested ifdef
        if (both_features == 1) begin
            $display("PASS: Nested ifdef (FEATURE_A && FEATURE_B)");
            pass_count++;
        end else begin
            $display("FAIL: Nested ifdef");
            fail_count++;
        end

        // Test 7: elsif chain
        if (MODE == 3) begin
            $display("PASS: elsif chain selected FEATURE_A branch");
            pass_count++;
        end else begin
            $display("FAIL: elsif chain: MODE=%0d", MODE);
            fail_count++;
        end

        // Test 8: MAKE_SIGNAL macro (token pasting style)
        sig1 = 8'hAB;
        sig2 = 8'hCD;
        if (sig1 == 8'hAB && sig2 == 8'hCD) begin
            $display("PASS: MAKE_SIGNAL macro");
            pass_count++;
        end else begin
            $display("FAIL: MAKE_SIGNAL macro");
            fail_count++;
        end

        // Test 9: Undef and redefine
`undef WIDTH
`define WIDTH 16
        if (`WIDTH == 16) begin
            $display("PASS: undef/redefine WIDTH=%0d", `WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: undef/redefine");
            fail_count++;
        end

        // Test 10: Macro in expression context
        begin
            int arr [`DEPTH];
            if ($size(arr) == 16) begin
                $display("PASS: Macro in array size");
                pass_count++;
            end else begin
                $display("FAIL: Macro in array size");
                fail_count++;
            end
        end

        // Summary
        $display("");
        $display("=================================");
        $display("Macro Advanced Tests: %0d passed, %0d failed", pass_count, fail_count);
        $display("=================================");

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
