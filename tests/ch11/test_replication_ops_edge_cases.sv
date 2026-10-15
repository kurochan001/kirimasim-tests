/*
:name: test_replication_ops_edge_cases
:description: Replication counts of 1 and more, nested replication and extension patterns
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_replication_ops_edge_cases.expected
*/
// Replication counts of 1 and more, nested replication and extension patterns
// IEEE 1800-2023 Section 11.4.12.1 Replication operator
// Tests corner cases: replication operations

`timescale 1ns/1ps

module test_replication_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] result8;
    logic [15:0] result16;
    logic [31:0] result32;

    initial begin
        $display("TEST: Replication operations edge cases");

        // Test 1: Replicate 1-bit to 8
        begin
            result8 = {8{1'b1}};
            if (result8 == 8'hFF) begin
                $display("  [PASS] Replicate 1-bit to 8");
                passed++;
            end else begin
                $display("  [FAIL] Rep1: %h", result8);
                failed++;
            end
        end

        // Test 2: Replicate 0-bit
        begin
            result8 = {8{1'b0}};
            if (result8 == 8'h00) begin
                $display("  [PASS] Replicate 0-bit");
                passed++;
            end else begin
                $display("  [FAIL] Rep0: %h", result8);
                failed++;
            end
        end

        // Test 3: Replicate 2-bits
        begin
            result8 = {4{2'b10}};
            if (result8 == 8'b10101010) begin
                $display("  [PASS] Replicate 2-bits");
                passed++;
            end else begin
                $display("  [FAIL] Rep2: %b", result8);
                failed++;
            end
        end

        // Test 4: Replicate nibble
        begin
            result16 = {4{4'hA}};
            if (result16 == 16'hAAAA) begin
                $display("  [PASS] Replicate nibble");
                passed++;
            end else begin
                $display("  [FAIL] RepNib: %h", result16);
                failed++;
            end
        end

        // Test 5: Replicate byte
        begin
            result32 = {4{8'hAB}};
            if (result32 == 32'hABABABAB) begin
                $display("  [PASS] Replicate byte");
                passed++;
            end else begin
                $display("  [FAIL] RepByte: %h", result32);
                failed++;
            end
        end

        // Test 6: Single replication
        begin
            result8 = {1{8'h55}};
            if (result8 == 8'h55) begin
                $display("  [PASS] Single replication");
                passed++;
            end else begin
                $display("  [FAIL] Single: %h", result8);
                failed++;
            end
        end

        // Test 7: Replication with byte
        begin
            result16 = {2{8'hAB}};
            if (result16 == 16'hABAB) begin
                $display("  [PASS] Replication with byte");
                passed++;
            end else begin
                $display("  [FAIL] RepByte16: %h", result16);
                failed++;
            end
        end

        // Test 8: Sign extension pattern
        begin
            static logic [7:0] val = 8'b10110100;
            result16 = {{8{val[7]}}, val};
            if (result16 == 16'hFFB4) begin
                $display("  [PASS] Sign extension pattern");
                passed++;
            end else begin
                $display("  [FAIL] SignExt: %h", result16);
                failed++;
            end
        end

        // Test 9: Zero extension pattern
        begin
            result16 = {{8{1'b0}}, 8'hAB};
            if (result16 == 16'h00AB) begin
                $display("  [PASS] Zero extension pattern");
                passed++;
            end else begin
                $display("  [FAIL] ZeroExt: %h", result16);
                failed++;
            end
        end

        // Test 10: Double replication
        begin
            result16 = {2{{2{4'hF}}}};
            if (result16 == 16'hFFFF) begin
                $display("  [PASS] Double replication");
                passed++;
            end else begin
                $display("  [FAIL] Double: %h", result16);
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
