/*
:name: test_hierarchy_edge_cases
:description: Test: Hierarchy edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchy_edge_cases.expected
*/
// Test: Hierarchy edge cases
// IEEE 1800-2023 Section 23.3.2 Module Hierarchy
// Tests corner cases: instantiation, hierarchical access

`timescale 1ns/1ps

// Simple child module
module child_module(
    input logic [7:0] in_data,
    output logic [7:0] out_data
);
    assign out_data = in_data + 1;
endmodule

// Another child module
module adder_child(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module test_hierarchy_edge_cases;
    int passed = 0;
    int failed = 0;

    // Signals
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic [7:0] add_a, add_b, add_sum;

    // Module instances
    child_module u_child(
        .in_data(data_in),
        .out_data(data_out)
    );

    adder_child u_adder(
        .a(add_a),
        .b(add_b),
        .sum(add_sum)
    );

    initial begin
        $display("TEST: Hierarchy edge cases");

        // Initialize
        data_in = 0;
        add_a = 0;
        add_b = 0;

        // Test 1: Single instance
        begin
            data_in = 8'h10;
            #1;
            if (data_out == 8'h11) begin
                $display("  [PASS] Single instance");
                passed++;
            end else begin
                $display("  [FAIL] Single: %h", data_out);
                failed++;
            end
        end

        // Test 2: Second instance
        begin
            add_a = 8'h20;
            add_b = 8'h30;
            #1;
            if (add_sum == 8'h50) begin
                $display("  [PASS] Second instance");
                passed++;
            end else begin
                $display("  [FAIL] Second: %h", add_sum);
                failed++;
            end
        end

        // Test 3: Instance update
        begin
            data_in = 8'h50;
            #1;
            if (data_out == 8'h51) begin
                $display("  [PASS] Instance update");
                passed++;
            end else begin
                $display("  [FAIL] Update: %h", data_out);
                failed++;
            end
        end

        // Test 4: Multiple inputs
        begin
            add_a = 8'hAA;
            add_b = 8'h55;
            #1;
            if (add_sum == 8'hFF) begin
                $display("  [PASS] Multiple inputs");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %h", add_sum);
                failed++;
            end
        end

        // Test 5: Zero propagation
        begin
            data_in = 8'h00;
            #1;
            if (data_out == 8'h01) begin
                $display("  [PASS] Zero propagation");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %h", data_out);
                failed++;
            end
        end

        // Test 6: Max value
        begin
            data_in = 8'hFE;
            #1;
            if (data_out == 8'hFF) begin
                $display("  [PASS] Max value");
                passed++;
            end else begin
                $display("  [FAIL] Max: %h", data_out);
                failed++;
            end
        end

        // Test 7: Overflow handling
        begin
            data_in = 8'hFF;
            #1;
            if (data_out == 8'h00) begin
                $display("  [PASS] Overflow handling");
                passed++;
            end else begin
                $display("  [FAIL] Overflow: %h", data_out);
                failed++;
            end
        end

        // Test 8: Adder zero
        begin
            add_a = 0;
            add_b = 0;
            #1;
            if (add_sum == 0) begin
                $display("  [PASS] Adder zero");
                passed++;
            end else begin
                $display("  [FAIL] Add0: %h", add_sum);
                failed++;
            end
        end

        // Test 9: Sequential updates
        begin
            data_in = 8'h01;
            #1;
            data_in = 8'h02;
            #1;
            data_in = 8'h03;
            #1;
            if (data_out == 8'h04) begin
                $display("  [PASS] Sequential updates");
                passed++;
            end else begin
                $display("  [FAIL] Seq: %h", data_out);
                failed++;
            end
        end

        // Test 10: Parallel instances
        begin
            data_in = 8'h10;
            add_a = 8'h10;
            add_b = 8'h10;
            #1;
            if (data_out == 8'h11 && add_sum == 8'h20) begin
                $display("  [PASS] Parallel instances");
                passed++;
            end else begin
                $display("  [FAIL] Parallel");
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
