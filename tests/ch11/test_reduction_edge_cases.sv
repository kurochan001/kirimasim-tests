/*
:name: test_reduction_edge_cases
:description: Reduction operators, including a single-bit operand
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.9: Reduction operator edge cases
// Tests for &, |, ^, ~&, ~|, ~^ operators

module test_reduction_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] val8;
    logic [3:0] val4;
    logic result;

    initial begin
        // Test 1: AND reduction all 1s
        test_count++;
        val8 = 8'hFF;
        result = &val8;
        if (result == 1) begin
            pass_count++;
            $display("Test 1 PASS: &FF = %b", result);
        end else begin
            $display("Test 1 FAIL: &FF unexpected = %b", result);
        end

        // Test 2: AND reduction with 0
        test_count++;
        val8 = 8'hFE;
        result = &val8;
        if (result == 0) begin
            pass_count++;
            $display("Test 2 PASS: &FE = %b", result);
        end else begin
            $display("Test 2 FAIL: &FE unexpected = %b", result);
        end

        // Test 3: OR reduction any 1
        test_count++;
        val8 = 8'h01;
        result = |val8;
        if (result == 1) begin
            pass_count++;
            $display("Test 3 PASS: |01 = %b", result);
        end else begin
            $display("Test 3 FAIL: |01 unexpected = %b", result);
        end

        // Test 4: OR reduction all 0s
        test_count++;
        val8 = 8'h00;
        result = |val8;
        if (result == 0) begin
            pass_count++;
            $display("Test 4 PASS: |00 = %b", result);
        end else begin
            $display("Test 4 FAIL: |00 unexpected = %b", result);
        end

        // Test 5: XOR reduction even 1s
        test_count++;
        val8 = 8'h0F;  // 4 ones
        result = ^val8;
        if (result == 0) begin
            pass_count++;
            $display("Test 5 PASS: ^0F = %b (even)", result);
        end else begin
            $display("Test 5 FAIL: ^0F unexpected = %b", result);
        end

        // Test 6: XOR reduction odd 1s
        test_count++;
        val8 = 8'h07;  // 3 ones
        result = ^val8;
        if (result == 1) begin
            pass_count++;
            $display("Test 6 PASS: ^07 = %b (odd)", result);
        end else begin
            $display("Test 6 FAIL: ^07 unexpected = %b", result);
        end

        // Test 7: NAND reduction
        test_count++;
        val8 = 8'hFF;
        result = ~&val8;
        if (result == 0) begin
            pass_count++;
            $display("Test 7 PASS: ~&FF = %b", result);
        end else begin
            $display("Test 7 FAIL: ~&FF unexpected = %b", result);
        end

        // Test 8: NOR reduction
        test_count++;
        val8 = 8'h00;
        result = ~|val8;
        if (result == 1) begin
            pass_count++;
            $display("Test 8 PASS: ~|00 = %b", result);
        end else begin
            $display("Test 8 FAIL: ~|00 unexpected = %b", result);
        end

        // Test 9: XNOR reduction even
        test_count++;
        val8 = 8'h0F;
        result = ~^val8;
        if (result == 1) begin
            pass_count++;
            $display("Test 9 PASS: ~^0F = %b", result);
        end else begin
            $display("Test 9 FAIL: ~^0F unexpected = %b", result);
        end

        // Test 10: Small width
        test_count++;
        val4 = 4'b1010;
        result = ^val4;
        if (result == 0) begin
            pass_count++;
            $display("Test 10 PASS: ^1010 = %b", result);
        end else begin
            $display("Test 10 FAIL: ^1010 unexpected = %b", result);
        end

        // Test 11: Single bit
        test_count++;
        begin
            static logic [0:0] single = 1'b1;
            result = &single;
            if (result == 1) begin
                pass_count++;
                $display("Test 11 PASS: &single = %b", result);
            end else begin
                $display("Test 11 FAIL: Single unexpected = %b", result);
            end
        end

        // Test 12: Alternating pattern
        test_count++;
        val8 = 8'hAA;
        result = ^val8;
        if (result == 0) begin
            pass_count++;
            $display("Test 12 PASS: ^AA = %b", result);
        end else begin
            $display("Test 12 FAIL: ^AA unexpected = %b", result);
        end

        $display("=== Reduction Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
