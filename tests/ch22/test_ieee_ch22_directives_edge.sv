/*
:name: test_ieee_ch22_directives_edge
:description: Chapter 22: Compiler Directives - Edge Cases
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ieee_ch22_directives_edge.expected
*/
// IEEE 1800-2023 Chapter 22: Compiler Directives - Edge Cases

`define WIDTH 8
`define DEPTH 16
`define EMPTY
`define FUNC_MACRO(x, y) ((x) + (y))
`define STR_MACRO(s) `"s`"
`define CONCAT_MACRO(a, b) a``b

module test_ieee_ch22_directives_edge;
    int pass_count = 0;
    int fail_count = 0;

    // Use WIDTH and DEPTH macros
    logic [`WIDTH-1:0] data;
    logic [`WIDTH-1:0] mem [`DEPTH-1:0];

    initial begin
        // Test 1: Simple macro expansion
        data = `WIDTH'd100;
        if ($bits(data) == `WIDTH) begin
            $display("Test 1 PASS: Simple macro expansion");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Function-like macro
        begin
            static int result = `FUNC_MACRO(10, 20);
            if (result == 30) begin
                $display("Test 2 PASS: Function-like macro");
                pass_count++;
            end else begin
                $display("Test 2 FAIL: result=%0d", result);
                fail_count++;
            end
        end

        // Test 3: Macro with expressions
        begin
            static int a = 5;
            static int b = 3;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = `FUNC_MACRO(a * 2, b + 1);
            if (result == 14) begin  // (5*2) + (3+1) = 14
                $display("Test 3 PASS: Macro with expressions");
                pass_count++;
            end else begin
                $display("Test 3 FAIL: result=%0d", result);
                fail_count++;
            end
        end

        // Test 4: ifdef/ifndef
`ifdef WIDTH
        $display("Test 4 PASS: ifdef WIDTH defined");
        pass_count++;
`else
        $display("Test 4 FAIL: ifdef WIDTH not defined");
        fail_count++;
`endif

        // Test 5: ifndef for undefined macro
`ifndef UNDEFINED_MACRO
        $display("Test 5 PASS: ifndef UNDEFINED_MACRO");
        pass_count++;
`else
        $display("Test 5 FAIL");
        fail_count++;
`endif

        // Test 6: Nested ifdef
`ifdef WIDTH
    `ifdef DEPTH
        $display("Test 6 PASS: Nested ifdef");
        pass_count++;
    `else
        $display("Test 6 FAIL: DEPTH not defined");
        fail_count++;
    `endif
`else
        $display("Test 6 FAIL: WIDTH not defined");
        fail_count++;
`endif

        // Test 7: Empty macro
`ifdef EMPTY
        $display("Test 7 PASS: Empty macro defined");
        pass_count++;
`else
        $display("Test 7 FAIL");
        fail_count++;
`endif

        // Test 8: Macro arithmetic
        begin
            static int size_val = `WIDTH * `DEPTH;
            if (size_val == 128) begin  // 8 * 16 = 128
                $display("Test 8 PASS: Macro arithmetic");
                pass_count++;
            end else begin
                $display("Test 8 FAIL: Macro arithmetic (size=%0d)", size_val);
                fail_count++;
            end
        end

        // Test 9: Memory array with macro dimensions
        mem[0] = 8'hAA;
        mem[`DEPTH-1] = 8'h55;
        if (mem[0] == 8'hAA && mem[15] == 8'h55) begin
            $display("Test 9 PASS: Memory array with macro dimensions");
            pass_count++;
        end else begin
            $display("Test 9 FAIL");
            fail_count++;
        end

        // Test 10: Conditional compilation with else
`ifdef UNDEFINED
        $display("Test 10 FAIL: Should not reach here");
        fail_count++;
`else
        $display("Test 10 PASS: Conditional else branch");
        pass_count++;
`endif

        $display("=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end
endmodule
