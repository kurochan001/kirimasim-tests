/*
:name: test_param_override_edge_cases
:description: Test: Parameter override edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_override_edge_cases.expected
*/
// Test: Parameter override edge cases
// IEEE 1800-2023 Section 23.10 Overriding Parameters
// Tests corner cases: parameter overrides

`timescale 1ns/1ps

module param_mod #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    assign data_out = data_in;
endmodule

module test_param_override_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] in8, out8;
    logic [15:0] in16, out16;
    logic [31:0] in32, out32;

    // Default parameters
    param_mod u_default(.data_in(in8), .data_out(out8));

    // Override WIDTH
    param_mod #(.WIDTH(16)) u_w16(.data_in(in16), .data_out(out16));

    // Override both
    param_mod #(.WIDTH(32), .DEPTH(64)) u_w32(.data_in(in32), .data_out(out32));

    initial begin
        $display("TEST: Parameter override edge cases");

        // Test 1: Default width
        begin
            in8 = 8'hAB;
            #1;
            if (out8 == 8'hAB) begin
                $display("  [PASS] Default width");
                passed++;
            end else begin
                $display("  [FAIL] DefWidth: %h", out8);
                failed++;
            end
        end

        // Test 2: Override to 16-bit
        begin
            in16 = 16'h1234;
            #1;
            if (out16 == 16'h1234) begin
                $display("  [PASS] Override to 16-bit");
                passed++;
            end else begin
                $display("  [FAIL] O16: %h", out16);
                failed++;
            end
        end

        // Test 3: Override to 32-bit
        begin
            in32 = 32'hDEADBEEF;
            #1;
            if (out32 == 32'hDEADBEEF) begin
                $display("  [PASS] Override to 32-bit");
                passed++;
            end else begin
                $display("  [FAIL] O32: %h", out32);
                failed++;
            end
        end

        // Test 4: Multiple assignments
        begin
            in8 = 8'h11;
            in16 = 16'h2222;
            in32 = 32'h33333333;
            #1;
            if (out8 == 8'h11 && out16 == 16'h2222 && out32 == 32'h33333333) begin
                $display("  [PASS] Multiple assignments");
                passed++;
            end else begin
                $display("  [FAIL] MultAssign");
                failed++;
            end
        end

        // Test 5: Zero value
        begin
            in8 = 0;
            in16 = 0;
            in32 = 0;
            #1;
            if (out8 == 0 && out16 == 0 && out32 == 0) begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero");
                failed++;
            end
        end

        // Test 6: Max 8-bit
        begin
            in8 = 8'hFF;
            #1;
            if (out8 == 8'hFF) begin
                $display("  [PASS] Max 8-bit");
                passed++;
            end else begin
                $display("  [FAIL] Max8: %h", out8);
                failed++;
            end
        end

        // Test 7: Max 16-bit
        begin
            in16 = 16'hFFFF;
            #1;
            if (out16 == 16'hFFFF) begin
                $display("  [PASS] Max 16-bit");
                passed++;
            end else begin
                $display("  [FAIL] Max16: %h", out16);
                failed++;
            end
        end

        // Test 8: Max 32-bit
        begin
            in32 = 32'hFFFFFFFF;
            #1;
            if (out32 == 32'hFFFFFFFF) begin
                $display("  [PASS] Max 32-bit");
                passed++;
            end else begin
                $display("  [FAIL] Max32: %h", out32);
                failed++;
            end
        end

        // Test 9: Bit patterns
        begin
            in8 = 8'b10101010;
            in16 = 16'b1010101010101010;
            #1;
            if (out8 == 8'hAA && out16 == 16'hAAAA) begin
                $display("  [PASS] Bit patterns");
                passed++;
            end else begin
                $display("  [FAIL] Patterns");
                failed++;
            end
        end

        // Test 10: Sequential updates
        begin
            for (int i = 0; i < 5; i++) begin
                in8 = i;
                #1;
            end
            if (out8 == 4) begin
                $display("  [PASS] Sequential updates");
                passed++;
            end else begin
                $display("  [FAIL] SeqUpd: %0d", out8);
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
