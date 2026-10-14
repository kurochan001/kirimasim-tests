/*
:name: test_interface_param_edge_cases
:description: Test: Interface parameter edge cases
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.8 25.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_param_edge_cases.expected
*/
// Test: Interface parameter edge cases
// IEEE 1800-2023 Section 25.10 Parameterized Interfaces
// Tests corner cases: parameterized interfaces

`timescale 1ns/1ps

interface param_if #(parameter WIDTH = 8);
    logic [WIDTH-1:0] data;
    logic valid;

    modport master (output data, output valid);
    modport slave (input data, input valid);
endinterface

module test_interface_param_edge_cases;
    int passed = 0;
    int failed = 0;

    param_if #(.WIDTH(8)) if8();
    param_if #(.WIDTH(16)) if16();
    param_if #(.WIDTH(32)) if32();

    initial begin
        $display("TEST: Interface parameter edge cases");

        // Test 1: 8-bit interface
        begin
            if8.data = 8'hAB;
            if (if8.data == 8'hAB) begin
                $display("  [PASS] 8-bit interface");
                passed++;
            end else begin
                $display("  [FAIL] If8: %h", if8.data);
                failed++;
            end
        end

        // Test 2: 16-bit interface
        begin
            if16.data = 16'h1234;
            if (if16.data == 16'h1234) begin
                $display("  [PASS] 16-bit interface");
                passed++;
            end else begin
                $display("  [FAIL] If16: %h", if16.data);
                failed++;
            end
        end

        // Test 3: 32-bit interface
        begin
            if32.data = 32'hDEADBEEF;
            if (if32.data == 32'hDEADBEEF) begin
                $display("  [PASS] 32-bit interface");
                passed++;
            end else begin
                $display("  [FAIL] If32: %h", if32.data);
                failed++;
            end
        end

        // Test 4: Valid signal 8-bit
        begin
            if8.valid = 1;
            if (if8.valid == 1) begin
                $display("  [PASS] Valid signal 8-bit");
                passed++;
            end else begin
                $display("  [FAIL] Valid8: %b", if8.valid);
                failed++;
            end
        end

        // Test 5: Valid signal 16-bit
        begin
            if16.valid = 1;
            if (if16.valid == 1) begin
                $display("  [PASS] Valid signal 16-bit");
                passed++;
            end else begin
                $display("  [FAIL] Valid16: %b", if16.valid);
                failed++;
            end
        end

        // Test 6: Data width 8
        begin
            if ($bits(if8.data) == 8) begin
                $display("  [PASS] Data width 8");
                passed++;
            end else begin
                $display("  [FAIL] Width8: %0d", $bits(if8.data));
                failed++;
            end
        end

        // Test 7: Data width 16
        begin
            if ($bits(if16.data) == 16) begin
                $display("  [PASS] Data width 16");
                passed++;
            end else begin
                $display("  [FAIL] Width16: %0d", $bits(if16.data));
                failed++;
            end
        end

        // Test 8: Data width 32
        begin
            if ($bits(if32.data) == 32) begin
                $display("  [PASS] Data width 32");
                passed++;
            end else begin
                $display("  [FAIL] Width32: %0d", $bits(if32.data));
                failed++;
            end
        end

        // Test 9: Max value 8-bit
        begin
            if8.data = 8'hFF;
            if (if8.data == 8'hFF) begin
                $display("  [PASS] Max value 8-bit");
                passed++;
            end else begin
                $display("  [FAIL] Max8: %h", if8.data);
                failed++;
            end
        end

        // Test 10: Zero value
        begin
            if32.data = 0;
            if (if32.data == 0) begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %h", if32.data);
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
