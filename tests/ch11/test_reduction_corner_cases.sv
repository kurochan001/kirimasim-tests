/*
:name: test_reduction_corner_cases
:description: Reduction operators on all-0, all-1, all-x, all-z, single-bit and mixed operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_reduction_corner_cases.expected
*/
// IEEE 1800-2023 §11.4.9: Reduction operator corner cases
// Tests for all-X, all-Z, single-bit edge cases

module test_reduction_corner_cases;
    int pass_count = 0;
    int test_count = 0;

    // Test variables
    logic [7:0] all_zeros = 8'b0000_0000;
    logic [7:0] all_ones = 8'b1111_1111;
    logic [7:0] all_x = 8'bxxxx_xxxx;
    logic [7:0] all_z = 8'bzzzz_zzzz;
    logic [7:0] mixed_xz = 8'b10xz_xz01;
    logic [0:0] single_bit_0 = 1'b0;
    logic [0:0] single_bit_1 = 1'b1;
    logic [0:0] single_bit_x = 1'bx;
    logic [0:0] single_bit_z = 1'bz;
    logic [31:0] large_val = 32'hFFFF_FFFF;

    initial begin
        // Test 1: Reduction AND on all zeros
        test_count++;
        if (&all_zeros === 1'b0) begin
            pass_count++;
            $display("Test 1 PASS: &(all zeros) = 0");
        end else begin
            $display("Test 1 FAIL: &(all zeros) = %b", &all_zeros);
        end

        // Test 2: Reduction AND on all ones
        test_count++;
        if (&all_ones === 1'b1) begin
            pass_count++;
            $display("Test 2 PASS: &(all ones) = 1");
        end else begin
            $display("Test 2 FAIL: &(all ones) = %b", &all_ones);
        end

        // Test 3: Reduction OR on all zeros
        test_count++;
        if (|all_zeros === 1'b0) begin
            pass_count++;
            $display("Test 3 PASS: |(all zeros) = 0");
        end else begin
            $display("Test 3 FAIL: |(all zeros) = %b", |all_zeros);
        end

        // Test 4: Reduction OR on all ones
        test_count++;
        if (|all_ones === 1'b1) begin
            pass_count++;
            $display("Test 4 PASS: |(all ones) = 1");
        end else begin
            $display("Test 4 FAIL: |(all ones) = %b", |all_ones);
        end

        // Test 5: Reduction XOR on all zeros (even parity)
        test_count++;
        if (^all_zeros === 1'b0) begin
            pass_count++;
            $display("Test 5 PASS: ^(all zeros) = 0");
        end else begin
            $display("Test 5 FAIL: ^(all zeros) = %b", ^all_zeros);
        end

        // Test 6: Reduction XOR on all ones (8 bits = even parity)
        test_count++;
        if (^all_ones === 1'b0) begin
            pass_count++;
            $display("Test 6 PASS: ^(8'hFF) = 0 (even parity)");
        end else begin
            $display("Test 6 FAIL: ^(all ones) = %b", ^all_ones);
        end

        // Test 7: Reduction NAND on all ones
        test_count++;
        if (~&all_ones === 1'b0) begin
            pass_count++;
            $display("Test 7 PASS: ~&(all ones) = 0");
        end else begin
            $display("Test 7 FAIL: ~&(all ones) = %b", ~&all_ones);
        end

        // Test 8: Reduction NOR on all zeros
        test_count++;
        if (~|all_zeros === 1'b1) begin
            pass_count++;
            $display("Test 8 PASS: ~|(all zeros) = 1");
        end else begin
            $display("Test 8 FAIL: ~|(all zeros) = %b", ~|all_zeros);
        end

        // Test 9: Reduction XNOR on all zeros
        test_count++;
        if (~^all_zeros === 1'b1) begin
            pass_count++;
            $display("Test 9 PASS: ~^(all zeros) = 1");
        end else begin
            $display("Test 9 FAIL: ~^(all zeros) = %b", ~^all_zeros);
        end

        // Test 10: Single bit reduction AND
        test_count++;
        if (&single_bit_1 === 1'b1 && &single_bit_0 === 1'b0) begin
            pass_count++;
            $display("Test 10 PASS: Single bit reduction AND");
        end else begin
            $display("Test 10 FAIL: &1=%b &0=%b", &single_bit_1, &single_bit_0);
        end

        // Test 11: Single bit reduction OR
        test_count++;
        if (|single_bit_1 === 1'b1 && |single_bit_0 === 1'b0) begin
            pass_count++;
            $display("Test 11 PASS: Single bit reduction OR");
        end else begin
            $display("Test 11 FAIL: |1=%b |0=%b", |single_bit_1, |single_bit_0);
        end

        // Test 12: Single bit reduction XOR
        test_count++;
        if (^single_bit_1 === 1'b1 && ^single_bit_0 === 1'b0) begin
            pass_count++;
            $display("Test 12 PASS: Single bit reduction XOR");
        end else begin
            $display("Test 12 FAIL: ^1=%b ^0=%b", ^single_bit_1, ^single_bit_0);
        end

        // Test 13: Reduction on X values
        test_count++;
        // AND of all x bits is x (11.4.9)
        if (&all_x === 1'bx) begin
            pass_count++;
            $display("Test 13 PASS: &(all X) = x");
        end else begin
            $display("Test 13 FAIL: &(all X) wrong");
        end

        // Test 14: Reduction on Z values
        test_count++;
        // z bits act as x in a reduction (11.4.9), so the result is x
        if (&all_z === 1'bx) begin
            pass_count++;
            $display("Test 14 PASS: &(all Z) = x");
        end else begin
            $display("Test 14 FAIL: &(all Z) = %b", &all_z);
        end

        // Test 15: Large value reduction
        test_count++;
        if (&large_val === 1'b1) begin
            pass_count++;
            $display("Test 15 PASS: &(32'hFFFFFFFF) = 1");
        end else begin
            $display("Test 15 FAIL: &(large) = %b", &large_val);
        end

        // Test 16: Alternating pattern XOR
        test_count++;
        begin
            static logic [7:0] alt = 8'b1010_1010;  // 4 ones = even parity
            if (^alt === 1'b0) begin
                pass_count++;
                $display("Test 16 PASS: ^(alternating) = 0");
            end else begin
                $display("Test 16 FAIL: ^(alternating) = %b", ^alt);
            end
        end

        // Test 17: 7 ones XOR (odd parity)
        test_count++;
        begin
            static logic [7:0] seven_ones = 8'b0111_1111;
            if (^seven_ones === 1'b1) begin
                pass_count++;
                $display("Test 17 PASS: ^(7 ones) = 1 (odd parity)");
            end else begin
                $display("Test 17 FAIL: ^(7 ones) = %b", ^seven_ones);
            end
        end

        // Test 18: Mixed X/Z reduction OR
        test_count++;
        begin
            static logic [3:0] mix = 4'b1xz0;
            if (|mix === 1'b1) begin  // Has a definite 1
                pass_count++;
                $display("Test 18 PASS: |(1xz0) = 1");
            end else begin
                $display("Test 18 FAIL: |(1xz0) = %b", |mix);
            end
        end

        // Test 19: Mixed X/Z reduction AND
        test_count++;
        begin
            static logic [3:0] mix = 4'b1xz0;
            if (&mix === 1'b0) begin  // Has a definite 0
                pass_count++;
                $display("Test 19 PASS: &(1xz0) = 0");
            end else begin
                $display("Test 19 FAIL: &(1xz0) = %b", &mix);
            end
        end

        // Test 20: Literal reduction
        test_count++;
        if (&4'b1111 === 1'b1 && |4'b0000 === 1'b0) begin
            pass_count++;
            $display("Test 20 PASS: Literal reductions work");
        end else begin
            $display("Test 20 FAIL: Literal reduction issue");
        end

        $display("=== Reduction Corner Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
