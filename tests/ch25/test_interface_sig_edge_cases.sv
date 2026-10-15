/*
:name: test_interface_sig_edge_cases
:description: Test: Interface signal edge cases
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_sig_edge_cases.expected
*/
// Test: Interface signal edge cases
// IEEE 1800-2023 Section 25 Interfaces
// Tests corner cases: interface signal access

`timescale 1ns/1ps

interface simple_if;
    logic [7:0] data;
    logic valid;
    logic ready;
endinterface

module test_interface_sig_edge_cases;
    int passed = 0;
    int failed = 0;

    simple_if sif();

    initial begin
        $display("TEST: Interface signal edge cases");

        // Test 1: Initial data
        begin
            sif.data = 0;
            #1;
            if (sif.data == 0) begin
                $display("  [PASS] Initial data");
                passed++;
            end else begin
                $display("  [FAIL] Init: %0h", sif.data);
                failed++;
            end
        end

        // Test 2: Write data
        begin
            sif.data = 8'hAB;
            #1;
            if (sif.data == 8'hAB) begin
                $display("  [PASS] Write data");
                passed++;
            end else begin
                $display("  [FAIL] Write: %0h", sif.data);
                failed++;
            end
        end

        // Test 3: Valid signal
        begin
            sif.valid = 1;
            #1;
            if (sif.valid == 1) begin
                $display("  [PASS] Valid signal");
                passed++;
            end else begin
                $display("  [FAIL] Valid: %0d", sif.valid);
                failed++;
            end
        end

        // Test 4: Ready signal
        begin
            sif.ready = 1;
            #1;
            if (sif.ready == 1) begin
                $display("  [PASS] Ready signal");
                passed++;
            end else begin
                $display("  [FAIL] Ready: %0d", sif.ready);
                failed++;
            end
        end

        // Test 5: Toggle valid
        begin
            sif.valid = 0;
            #1;
            if (sif.valid == 0) begin
                $display("  [PASS] Toggle valid");
                passed++;
            end else begin
                $display("  [FAIL] Toggle: %0d", sif.valid);
                failed++;
            end
        end

        // Test 6: Multiple signals
        begin
            sif.data = 8'hCD;
            sif.valid = 1;
            sif.ready = 0;
            #1;
            if (sif.data == 8'hCD && sif.valid == 1 && sif.ready == 0) begin
                $display("  [PASS] Multiple signals");
                passed++;
            end else begin
                $display("  [FAIL] Multi");
                failed++;
            end
        end

        // Test 7: Data increment
        begin
            sif.data = sif.data + 1;
            #1;
            if (sif.data == 8'hCE) begin
                $display("  [PASS] Data increment");
                passed++;
            end else begin
                $display("  [FAIL] Inc: %0h", sif.data);
                failed++;
            end
        end

        // Test 8: Max data
        begin
            sif.data = 8'hFF;
            #1;
            if (sif.data == 8'hFF) begin
                $display("  [PASS] Max data");
                passed++;
            end else begin
                $display("  [FAIL] Max: %0h", sif.data);
                failed++;
            end
        end

        // Test 9: Zero all
        begin
            sif.data = 0;
            sif.valid = 0;
            sif.ready = 0;
            #1;
            if (sif.data == 0 && sif.valid == 0 && sif.ready == 0) begin
                $display("  [PASS] Zero all");
                passed++;
            end else begin
                $display("  [FAIL] ZeroAll");
                failed++;
            end
        end

        // Test 10: Pattern write
        begin
            sif.data = 8'h55;
            #1;
            if (sif.data == 8'h55) begin
                $display("  [PASS] Pattern write");
                passed++;
            end else begin
                $display("  [FAIL] Pattern: %0h", sif.data);
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
