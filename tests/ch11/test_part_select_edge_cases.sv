/*
:name: test_part_select_edge_cases
:description: Reading and writing constant and indexed part-selects
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_part_select_edge_cases.expected
*/
// Reading and writing constant and indexed part-selects
// IEEE 1800-2023 Section 11.5.1 Vector part-select
// Tests corner cases: part selection operations

`timescale 1ns/1ps

module test_part_select_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [15:0] vec;
    logic [7:0] part;
    logic [3:0] nibble;
    int idx;

    initial begin
        $display("TEST: Part select edge cases");

        // Test 1: Lower byte select
        begin
            vec = 16'hABCD;
            part = vec[7:0];
            if (part == 8'hCD) begin
                $display("  [PASS] Lower byte select");
                passed++;
            end else begin
                $display("  [FAIL] Lower: %h", part);
                failed++;
            end
        end

        // Test 2: Upper byte select
        begin
            vec = 16'hABCD;
            part = vec[15:8];
            if (part == 8'hAB) begin
                $display("  [PASS] Upper byte select");
                passed++;
            end else begin
                $display("  [FAIL] Upper: %h", part);
                failed++;
            end
        end

        // Test 3: Nibble select
        begin
            vec = 16'h1234;
            nibble = vec[7:4];
            if (nibble == 4'h3) begin
                $display("  [PASS] Nibble select");
                passed++;
            end else begin
                $display("  [FAIL] Nibble: %h", nibble);
                failed++;
            end
        end

        // Test 4: Part select write
        begin
            vec = 16'h0000;
            vec[11:8] = 4'hF;
            if (vec == 16'h0F00) begin
                $display("  [PASS] Part select write");
                passed++;
            end else begin
                $display("  [FAIL] Write: %h", vec);
                failed++;
            end
        end

        // Test 5: Indexed part select +
        begin
            vec = 16'hABCD;
            idx = 4;
            part = vec[idx +: 8];  // vec[11:4]
            if (part == 8'hBC) begin
                $display("  [PASS] Indexed part select +");
                passed++;
            end else begin
                $display("  [FAIL] Idx+: %h", part);
                failed++;
            end
        end

        // Test 6: Indexed part select -
        begin
            vec = 16'hABCD;
            idx = 11;
            part = vec[idx -: 8];  // vec[11:4]
            if (part == 8'hBC) begin
                $display("  [PASS] Indexed part select -");
                passed++;
            end else begin
                $display("  [FAIL] Idx-: %h", part);
                failed++;
            end
        end

        // Test 7: Indexed write +
        begin
            vec = 16'h0000;
            idx = 8;
            vec[idx +: 4] = 4'hA;
            if (vec == 16'h0A00) begin
                $display("  [PASS] Indexed write +");
                passed++;
            end else begin
                $display("  [FAIL] IdxW+: %h", vec);
                failed++;
            end
        end

        // Test 8: Full width select
        begin
            vec = 16'hBEEF;
            if (vec[15:0] == 16'hBEEF) begin
                $display("  [PASS] Full width select");
                passed++;
            end else begin
                $display("  [FAIL] Full");
                failed++;
            end
        end

        // Test 9: Single bit as part
        begin
            vec = 16'b0000000000010000;
            if (vec[4:4] == 1'b1) begin
                $display("  [PASS] Single bit as part");
                passed++;
            end else begin
                $display("  [FAIL] Single");
                failed++;
            end
        end

        // Test 10: Adjacent parts
        begin
            vec = 16'hABCD;
            if (vec[15:12] == 4'hA && vec[11:8] == 4'hB &&
                vec[7:4] == 4'hC && vec[3:0] == 4'hD) begin
                $display("  [PASS] Adjacent parts");
                passed++;
            end else begin
                $display("  [FAIL] Adjacent");
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
