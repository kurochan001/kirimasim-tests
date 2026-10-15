/*
:name: test_parameters_edge_cases
:description: Localparams and overridden instance parameters
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 6.20.4 23.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameters_edge_cases.expected
*/
// Localparams and overridden instance parameters
// IEEE 1800-2023 Section 6.20 Parameters
// Tests corner cases: parameter override, localparam, type parameters

`timescale 1ns/1ps

// Module with parameters
module param_mod #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4,
    parameter logic [7:0] INIT_VAL = 8'hFF
) (
    input logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data
);
    assign out_data = in_data ^ INIT_VAL;
endmodule

module test_parameters_edge_cases;
    int passed = 0;
    int failed = 0;

    // Module-level localparams
    localparam int DEFAULT_VAL = 42;
    localparam int A = 10;
    localparam int B = 20;
    localparam int C = A + B;
    localparam logic [7:0] BYTE_VAL = 8'hAB;
    localparam int SIZE = 8;
    localparam int MASK = (1 << SIZE) - 1;
    localparam string MSG = "Hello";
    localparam real PI = 3.14159;
    localparam int NEG = -100;
    localparam int DIM = 4;

    // Instances with different parameters
    logic [7:0] in8, out8;
    logic [15:0] in16, out16;

    param_mod #(.WIDTH(8), .INIT_VAL(8'h00)) inst8 (
        .in_data(in8),
        .out_data(out8)
    );

    param_mod #(.WIDTH(16), .INIT_VAL(16'h0000)) inst16 (
        .in_data(in16),
        .out_data(out16)
    );

    initial begin
        $display("TEST: Parameters edge cases");

        // Test 1: Default parameter value
        if (DEFAULT_VAL == 42) begin
            $display("  [PASS] Localparam default value");
            passed++;
        end else begin
            $display("  [FAIL] Localparam issue");
            failed++;
        end

        // Test 2: Parameter in expression
        if (C == 30) begin
            $display("  [PASS] Parameter in expression");
            passed++;
        end else begin
            $display("  [FAIL] Expression: %0d", C);
            failed++;
        end

        // Test 3: Parameter width specification
        if (BYTE_VAL == 8'hAB) begin
            $display("  [PASS] Parameter with width");
            passed++;
        end else begin
            $display("  [FAIL] Width issue");
            failed++;
        end

        // Test 4: Parameter override in instance (8-bit)
        begin
            in8 = 8'hAA;
            #1;
            if (out8 == 8'hAA) begin  // XOR with 0x00
                $display("  [PASS] Parameter override (8-bit)");
                passed++;
            end else begin
                $display("  [FAIL] Override 8-bit: %h", out8);
                failed++;
            end
        end

        // Test 5: Parameter override in instance (16-bit)
        begin
            in16 = 16'h1234;
            #1;
            if (out16 == 16'h1234) begin  // XOR with 0x0000
                $display("  [PASS] Parameter override (16-bit)");
                passed++;
            end else begin
                $display("  [FAIL] Override 16-bit: %h", out16);
                failed++;
            end
        end

        // Test 6: Localparam computed from other params
        if (MASK == 255) begin
            $display("  [PASS] Computed localparam");
            passed++;
        end else begin
            $display("  [FAIL] Computed: %0d", MASK);
            failed++;
        end

        // Test 7: String parameter
        if (MSG == "Hello") begin
            $display("  [PASS] String parameter");
            passed++;
        end else begin
            $display("  [FAIL] String param");
            failed++;
        end

        // Test 8: Real parameter
        if (PI > 3.14 && PI < 3.15) begin
            $display("  [PASS] Real parameter");
            passed++;
        end else begin
            $display("  [FAIL] Real: %f", PI);
            failed++;
        end

        // Test 9: Negative parameter
        if (NEG == -100) begin
            $display("  [PASS] Negative parameter");
            passed++;
        end else begin
            $display("  [FAIL] Negative: %0d", NEG);
            failed++;
        end

        // Test 10: Parameter array dimensions
        begin
            int arr[DIM];
            arr[0] = 1;
            arr[DIM-1] = 99;
            if (arr[3] == 99) begin
                $display("  [PASS] Parameter in array dimension");
                passed++;
            end else begin
                $display("  [FAIL] Array dim");
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
