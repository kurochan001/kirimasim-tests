/*
:name: test_generate_loop_edge_cases
:description: Test: Generate loop edge cases
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop_edge_cases.expected
*/
// Test: Generate loop edge cases
// IEEE 1800-2023 Section 27.4 Loop generate constructs
// Tests corner cases: generate for loops

`timescale 1ns/1ps

module test_generate_loop_edge_cases;
    int passed = 0;
    int failed = 0;

    // Generate parameters
    localparam N = 4;

    // Generated signals
    logic [7:0] gen_data [N];
    logic [N-1:0] gen_valid;

    // Generate block
    generate
        for (genvar i = 0; i < N; i++) begin : gen_block
            assign gen_valid[i] = (gen_data[i] != 0);
        end
    endgenerate

    initial begin
        $display("TEST: Generate loop edge cases");

        // Initialize
        for (int i = 0; i < N; i++) gen_data[i] = 0;
        #1;

        // Test 1: Generated array size
        begin
            if ($size(gen_data) == N) begin
                $display("  [PASS] Generated array size");
                passed++;
            end else begin
                $display("  [FAIL] ArrSize: %0d", $size(gen_data));
                failed++;
            end
        end

        // Test 2: Generated valid width
        begin
            if ($bits(gen_valid) == N) begin
                $display("  [PASS] Generated valid width");
                passed++;
            end else begin
                $display("  [FAIL] ValidW: %0d", $bits(gen_valid));
                failed++;
            end
        end

        // Test 3: All zeros initial
        begin
            if (gen_valid == 0) begin
                $display("  [PASS] All zeros initial");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %b", gen_valid);
                failed++;
            end
        end

        // Test 4: Set first element
        begin
            gen_data[0] = 8'h01;
            #1;
            if (gen_valid[0] == 1) begin
                $display("  [PASS] Set first element");
                passed++;
            end else begin
                $display("  [FAIL] First: %b", gen_valid[0]);
                failed++;
            end
        end

        // Test 5: Set last element
        begin
            gen_data[N-1] = 8'hFF;
            #1;
            if (gen_valid[N-1] == 1) begin
                $display("  [PASS] Set last element");
                passed++;
            end else begin
                $display("  [FAIL] Last: %b", gen_valid[N-1]);
                failed++;
            end
        end

        // Test 6: Multiple valid
        begin
            gen_data[1] = 8'h10;
            gen_data[2] = 8'h20;
            #1;
            if (gen_valid[1] && gen_valid[2]) begin
                $display("  [PASS] Multiple valid");
                passed++;
            end else begin
                $display("  [FAIL] MultValid: %b", gen_valid);
                failed++;
            end
        end

        // Test 7: Clear element
        begin
            gen_data[0] = 0;
            #1;
            if (gen_valid[0] == 0) begin
                $display("  [PASS] Clear element");
                passed++;
            end else begin
                $display("  [FAIL] Clear: %b", gen_valid[0]);
                failed++;
            end
        end

        // Test 8: All valid
        begin
            for (int i = 0; i < N; i++) gen_data[i] = i + 1;
            #1;
            if (gen_valid == 4'b1111) begin
                $display("  [PASS] All valid");
                passed++;
            end else begin
                $display("  [FAIL] AllValid: %b", gen_valid);
                failed++;
            end
        end

        // Test 9: Toggle valid
        begin
            gen_data[2] = 0;
            #1;
            if (gen_valid[2] == 0) begin
                $display("  [PASS] Toggle valid");
                passed++;
            end else begin
                $display("  [FAIL] Toggle: %b", gen_valid[2]);
                failed++;
            end
        end

        // Test 10: Data values
        begin
            gen_data[0] = 8'hAA;
            gen_data[1] = 8'hBB;
            if (gen_data[0] == 8'hAA && gen_data[1] == 8'hBB) begin
                $display("  [PASS] Data values");
                passed++;
            end else begin
                $display("  [FAIL] DataVal: %h %h", gen_data[0], gen_data[1]);
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
