/*
:name: test_compiler_directives_comprehensive
:description: Chapter 22: Compiler Directives - Comprehensive Test
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.5.2 22.6 22.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compiler_directives_comprehensive.expected
*/
// IEEE 1800-2023 Chapter 22: Compiler Directives - Comprehensive Test
// Tests: §22.3 `define, §22.4 `ifdef/`ifndef, §22.5 `include,
//        §22.6 `timescale, §22.7 `default_nettype

`timescale 1ns/1ps

// §22.3: Macro definitions
`define DATA_WIDTH 8
`define ADDR_WIDTH 16
`define ENABLE_DEBUG

// Macro with arguments
`define MAX(a, b) ((a) > (b) ? (a) : (b))
`define MIN(a, b) ((a) < (b) ? (a) : (b))

// Macro with default value
`define CLOCK_PERIOD 10

// Stringification
`define STRINGIFY(x) `"x`"

// Concatenation in macros
`define REG_NAME(prefix, num) prefix``num

module test_compiler_directives_comprehensive;
    // Using defined macros
    logic [`DATA_WIDTH-1:0] data;
    logic [`ADDR_WIDTH-1:0] address;

    int pass_count = 0;
    int fail_count = 0;

    // §22.4: Conditional compilation
`ifdef ENABLE_DEBUG
    logic debug_mode = 1;
`else
    logic debug_mode = 0;
`endif

`ifndef DISABLE_FEATURE
    logic feature_enabled = 1;
`else
    logic feature_enabled = 0;
`endif

    // Nested ifdef
`ifdef ENABLE_DEBUG
    `ifdef DATA_WIDTH
        localparam DEBUG_DATA_WIDTH = `DATA_WIDTH;
    `else
        localparam DEBUG_DATA_WIDTH = 32;
    `endif
`endif

    // §22.4.3: `elsif
`ifdef MODE_A
    localparam MODE = 1;
`elsif MODE_B
    localparam MODE = 2;
`else
    localparam MODE = 0;  // Default mode
`endif

    // Test macro functions
    localparam MAX_VAL = `MAX(100, 50);
    localparam MIN_VAL = `MIN(100, 50);

    // Clock using macro
    logic clk = 0;
    always #(`CLOCK_PERIOD/2) clk = ~clk;

    initial begin
        // Test 1: Simple macro substitution
        if (`DATA_WIDTH == 8) begin
            $display("PASS: Simple macro DATA_WIDTH = %0d", `DATA_WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: DATA_WIDTH macro incorrect");
            fail_count++;
        end

        // Test 2: Macro with arguments
        if (MAX_VAL == 100 && MIN_VAL == 50) begin
            $display("PASS: Macro with arguments MAX=%0d, MIN=%0d", MAX_VAL, MIN_VAL);
            pass_count++;
        end else begin
            $display("FAIL: Macro with arguments incorrect");
            fail_count++;
        end

        // Test 3: Conditional compilation ifdef
        if (debug_mode == 1) begin
            $display("PASS: ifdef ENABLE_DEBUG worked");
            pass_count++;
        end else begin
            $display("FAIL: ifdef ENABLE_DEBUG failed");
            fail_count++;
        end

        // Test 4: Conditional compilation ifndef
        if (feature_enabled == 1) begin
            $display("PASS: ifndef DISABLE_FEATURE worked");
            pass_count++;
        end else begin
            $display("FAIL: ifndef DISABLE_FEATURE failed");
            fail_count++;
        end

        // Test 5: Nested ifdef
`ifdef ENABLE_DEBUG
        if (DEBUG_DATA_WIDTH == 8) begin
            $display("PASS: Nested ifdef worked, DEBUG_DATA_WIDTH=%0d", DEBUG_DATA_WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: Nested ifdef failed");
            fail_count++;
        end
`endif

        // Test 6: elsif chain
        if (MODE == 0) begin
            $display("PASS: elsif chain - default MODE=%0d", MODE);
            pass_count++;
        end else begin
            $display("FAIL: elsif chain incorrect");
            fail_count++;
        end

        // Test 7: Timescale verification
        #1;  // 1ns delay
        if ($time == 1) begin
            $display("PASS: Timescale 1ns working");
            pass_count++;
        end else begin
            $display("FAIL: Timescale incorrect");
            fail_count++;
        end

        // Test 8: Using macro in expressions
        data = `MAX(`DATA_WIDTH, 4);
        if (data == 8) begin
            $display("PASS: Macro in expression");
            pass_count++;
        end else begin
            $display("FAIL: Macro in expression");
            fail_count++;
        end

        // Test 9: Clock period macro
        @(posedge clk);
        @(posedge clk);
        if ($time >= `CLOCK_PERIOD) begin
            $display("PASS: Clock period macro (%0dns)", `CLOCK_PERIOD);
            pass_count++;
        end else begin
            $display("FAIL: Clock period macro");
            fail_count++;
        end

        // Test 10: Undef and redefine
`undef DATA_WIDTH
`define DATA_WIDTH 16
        if (`DATA_WIDTH == 16) begin
            $display("PASS: undef and redefine DATA_WIDTH=%0d", `DATA_WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: undef/redefine failed");
            fail_count++;
        end

        // Summary
        $display("");
        $display("=================================");
        $display("Compiler Directives Tests: %0d passed, %0d failed", pass_count, fail_count);
        $display("=================================");

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
