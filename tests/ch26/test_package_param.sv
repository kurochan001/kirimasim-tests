/*
:name: test_package_param
:description: Package parameters test
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3 6.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_param.expected
*/
// Package parameters test
package param_pkg;
    // Integer parameters
    parameter int WIDTH = 8;
    parameter int DEPTH = 16;
    parameter int MAX_COUNT = 100;

    // Logic parameters
    parameter logic [7:0] DEFAULT_VALUE = 8'hFF;
    parameter logic [3:0] NIBBLE_MASK = 4'b1010;

    // String parameter
    parameter string MODULE_NAME = "param_pkg";

    // Derived parameters
    localparam int TOTAL_BITS = WIDTH * DEPTH;
    localparam int ADDR_BITS = $clog2(DEPTH);

    // Real parameter
    parameter real PI = 3.14159;
    parameter real SCALE_FACTOR = 1.5;

    // Type-derived parameter
    typedef logic [WIDTH-1:0] data_t;
    localparam int DATA_SIZE = $bits(data_t);
endpackage

package calc_pkg;
    // Parameters used in calculations
    parameter int BASE = 10;
    parameter int MULTIPLIER = 5;
    localparam int COMPUTED = BASE * MULTIPLIER;

    // Array-like parameter
    parameter int LOOKUP [4] = '{0, 10, 20, 30};
endpackage

package override_pkg;
    // Default values that can be referenced
    parameter int SIZE = 32;
    parameter int COUNT = 4;
endpackage

module test_package_param;
    import param_pkg::*;
    import calc_pkg::*;

    int pass_count = 0;
    int fail_count = 0;

    // Use package parameters
    logic [WIDTH-1:0] data_var;
    data_t typed_var;

    initial begin
        #1;

        // Test 1: Integer parameters
        if (WIDTH == 8 && DEPTH == 16 && MAX_COUNT == 100) begin
            $display("PASS: Test 1 - Integer params (W=%0d, D=%0d, MAX=%0d)",
                     WIDTH, DEPTH, MAX_COUNT);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Integer params incorrect");
            fail_count++;
        end

        // Test 2: Derived parameters
        if (TOTAL_BITS == 128 && ADDR_BITS == 4) begin
            $display("PASS: Test 2 - Derived params (TOTAL=%0d, ADDR_BITS=%0d)",
                     TOTAL_BITS, ADDR_BITS);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Derived params incorrect (TOTAL=%0d, ADDR=%0d)",
                     TOTAL_BITS, ADDR_BITS);
            fail_count++;
        end

        // Test 3: Logic parameters
        data_var = DEFAULT_VALUE;
        if (data_var == 8'hFF && NIBBLE_MASK == 4'b1010) begin
            $display("PASS: Test 3 - Logic params (default=%h, mask=%b)",
                     DEFAULT_VALUE, NIBBLE_MASK);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Logic params incorrect");
            fail_count++;
        end

        // Test 4: Calculated parameters from another package
        if (BASE == 10 && MULTIPLIER == 5 && COMPUTED == 50) begin
            $display("PASS: Test 4 - Calculated params (BASE=%0d, MULT=%0d, COMP=%0d)",
                     BASE, MULTIPLIER, COMPUTED);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Calculated params incorrect");
            fail_count++;
        end

        // Test 5: Type-derived size and lookup array
        if (DATA_SIZE == 8 && LOOKUP[0] == 0 && LOOKUP[3] == 30) begin
            $display("PASS: Test 5 - Type size and lookup (SIZE=%0d, LOOKUP[3]=%0d)",
                     DATA_SIZE, LOOKUP[3]);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Type size or lookup incorrect");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
