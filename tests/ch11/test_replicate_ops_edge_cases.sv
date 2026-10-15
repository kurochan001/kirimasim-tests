/*
:name: test_replicate_ops_edge_cases
:description: Replication, nested replication and sign extension by replication
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_replicate_ops_edge_cases.expected
*/
// Replication, nested replication and sign extension by replication
// IEEE 1800-2023 Section 11.4.12.1 Replication operator
// Tests corner cases: replication operations

`timescale 1ns/1ps

module test_replicate_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        logic [7:0] byte_val;
        logic [15:0] word_val;
        logic [31:0] dword_val;

        $display("TEST: Replication operations edge cases");

        // Test 1: Basic replication 2x
        begin
            byte_val = {2{4'hA}};
            if (byte_val == 8'hAA) begin
                $display("  [PASS] Basic replication 2x");
                passed++;
            end else begin
                $display("  [FAIL] Rep2: %0h", byte_val);
                failed++;
            end
        end

        // Test 2: Replication 4x
        begin
            dword_val = {4{8'h55}};
            if (dword_val == 32'h55555555) begin
                $display("  [PASS] Replication 4x");
                passed++;
            end else begin
                $display("  [FAIL] Rep4: %0h", dword_val);
                failed++;
            end
        end

        // Test 3: Zero replication
        begin
            word_val = {4{4'h0}};
            if (word_val == 16'h0000) begin
                $display("  [PASS] Zero replication");
                passed++;
            end else begin
                $display("  [FAIL] ZeroRep: %0h", word_val);
                failed++;
            end
        end

        // Test 4: One replication
        begin
            word_val = {4{4'hF}};
            if (word_val == 16'hFFFF) begin
                $display("  [PASS] One replication");
                passed++;
            end else begin
                $display("  [FAIL] OneRep: %0h", word_val);
                failed++;
            end
        end

        // Test 5: Single bit replication
        begin
            byte_val = {8{1'b1}};
            if (byte_val == 8'hFF) begin
                $display("  [PASS] Single bit replication");
                passed++;
            end else begin
                $display("  [FAIL] BitRep: %0h", byte_val);
                failed++;
            end
        end

        // Test 6: Pattern replication
        begin
            word_val = {2{8'hAB}};
            if (word_val == 16'hABAB) begin
                $display("  [PASS] Pattern replication");
                passed++;
            end else begin
                $display("  [FAIL] Pattern: %0h", word_val);
                failed++;
            end
        end

        // Test 7: Nested replication
        begin
            dword_val = {2{{2{8'h12}}}};
            if (dword_val == 32'h12121212) begin
                $display("  [PASS] Nested replication");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0h", dword_val);
                failed++;
            end
        end

        // Test 8: Alternating bit replication
        begin
            byte_val = {4{2'b10}};
            if (byte_val == 8'hAA) begin
                $display("  [PASS] Alternating bit replication");
                passed++;
            end else begin
                $display("  [FAIL] AltBit: %0h", byte_val);
                failed++;
            end
        end

        // Test 9: Sign extension via replication
        begin
            static logic signed [7:0] s_val = -1;
            word_val = {{8{s_val[7]}}, s_val};
            if (word_val == 16'hFFFF) begin
                $display("  [PASS] Sign extension via replication");
                passed++;
            end else begin
                $display("  [FAIL] SignExt: %0h", word_val);
                failed++;
            end
        end

        // Test 10: Replicate and concat
        begin
            word_val = {{4{1'b1}}, {4{1'b0}}, 8'hAB};
            if (word_val == 16'hF0AB) begin
                $display("  [PASS] Replicate and concat");
                passed++;
            end else begin
                $display("  [FAIL] RepConcat: %0h", word_val);
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
