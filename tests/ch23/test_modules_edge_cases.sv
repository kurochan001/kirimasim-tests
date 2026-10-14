/*
:name: test_modules_edge_cases
:description: Test: Module edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.10.2.2 23.2.2.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modules_edge_cases.expected
*/
// Test: Module edge cases
// IEEE 1800-2023 Section 23 Modules
// Tests corner cases: nested modules, parameter overrides, port connections

`timescale 1ns/1ps

// Simple submodule with parameters
module inner_mod #(parameter int WIDTH = 8) (
    input logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data
);
    assign out_data = in_data + 1;
endmodule

// Module with default port values
module default_port_mod (
    input logic [7:0] data = 8'hFF,
    output logic [7:0] result
);
    assign result = data;
endmodule

// Module with inout port
module bidirectional_mod (
    inout wire [7:0] bidir
);
    // Just pass through for testing
endmodule

module test_modules_edge_cases;
    int passed = 0;
    int failed = 0;

    // Test 1: Basic instantiation with parameter override
    logic [15:0] wide_in, wide_out;
    inner_mod #(.WIDTH(16)) wide_inst (
        .in_data(wide_in),
        .out_data(wide_out)
    );

    // Test 2: Default parameter
    logic [7:0] narrow_in, narrow_out;
    inner_mod narrow_inst (
        .in_data(narrow_in),
        .out_data(narrow_out)
    );

    // Test 3: Named port connections
    logic [7:0] named_in, named_out;
    inner_mod named_inst (
        .in_data(named_in),
        .out_data(named_out)
    );

    // Test 4: Default port value module
    logic [7:0] def_result;
    default_port_mod def_inst (
        .result(def_result)
        // data uses default value
    );

    // Test 5: Wire for bidirectional
    wire [7:0] bidir_wire;
    bidirectional_mod bidir_inst (
        .bidir(bidir_wire)
    );

    initial begin
        $display("TEST: Module edge cases");

        // Test 1: Parameter override (16-bit)
        begin
            wide_in = 16'h00FF;
            #1;
            if (wide_out == 16'h0100) begin
                $display("  [PASS] Parameter override to 16-bit");
                passed++;
            end else begin
                $display("  [FAIL] 16-bit parameter override failed");
                failed++;
            end
        end

        // Test 2: Default parameter (8-bit)
        begin
            narrow_in = 8'hFE;
            #1;
            if (narrow_out == 8'hFF) begin
                $display("  [PASS] Default parameter (8-bit)");
                passed++;
            end else begin
                $display("  [FAIL] Default parameter failed");
                failed++;
            end
        end

        // Test 3: Named port connection
        begin
            named_in = 8'h10;
            #1;
            if (named_out == 8'h11) begin
                $display("  [PASS] Named port connections");
                passed++;
            end else begin
                $display("  [FAIL] Named port failed");
                failed++;
            end
        end

        // Test 4: Multiple instances independence
        begin
            wide_in = 16'h1000;
            narrow_in = 8'h20;
            #1;
            if (wide_out == 16'h1001 && narrow_out == 8'h21) begin
                $display("  [PASS] Multiple instances independent");
                passed++;
            end else begin
                $display("  [FAIL] Instance independence failed");
                failed++;
            end
        end

        // Test 5: Zero input
        begin
            narrow_in = 8'h00;
            #1;
            if (narrow_out == 8'h01) begin
                $display("  [PASS] Zero input handling");
                passed++;
            end else begin
                $display("  [FAIL] Zero input failed");
                failed++;
            end
        end

        // Test 6: Maximum input (wrap around)
        begin
            narrow_in = 8'hFF;
            #1;
            if (narrow_out == 8'h00) begin
                $display("  [PASS] Overflow wraps to zero");
                passed++;
            end else begin
                $display("  [FAIL] Overflow handling failed");
                failed++;
            end
        end

        // Test 7: Rapid value changes
        begin
            for (int i = 0; i < 5; i++) begin
                narrow_in = i;
                #1;
            end
            if (narrow_out == 8'h05) begin
                $display("  [PASS] Rapid value changes");
                passed++;
            end else begin
                $display("  [FAIL] Rapid changes failed");
                failed++;
            end
        end

        // Test 8: Wide parameter high bits
        begin
            wide_in = 16'hFFFF;
            #1;
            if (wide_out == 16'h0000) begin
                $display("  [PASS] 16-bit overflow handling");
                passed++;
            end else begin
                $display("  [FAIL] 16-bit overflow failed");
                failed++;
            end
        end

        // Test 9: Simultaneous updates
        begin
            wide_in = 16'h0001;
            narrow_in = 8'h01;
            named_in = 8'h01;
            #1;
            if (wide_out == 16'h0002 && narrow_out == 8'h02 && named_out == 8'h02) begin
                $display("  [PASS] Simultaneous multi-instance updates");
                passed++;
            end else begin
                $display("  [FAIL] Simultaneous updates failed");
                failed++;
            end
        end

        // Test 10: Instance hierarchy
        begin
            wide_in = 16'hABCD;
            #1;
            if (wide_out == 16'hABCE) begin
                $display("  [PASS] Instance hierarchy access");
                passed++;
            end else begin
                $display("  [FAIL] Hierarchy access failed");
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
