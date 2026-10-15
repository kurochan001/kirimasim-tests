/*
:name: test_array_reduction
:description: Array Reduction Methods (§7.12.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction.expected
*/
// IEEE 1800-2023 Array Reduction Methods (§7.12.3)
// Tests sum, product, and, or, xor

module test_array_reduction;
    initial begin
        static int arr[5] = '{1, 2, 3, 4, 5};
        static bit [3:0] bits[4] = '{4'b1111, 4'b0101, 4'b0011, 4'b1010};
        int result;
        bit [3:0] bit_result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: sum
        result = arr.sum();
        if (result == 15) begin
            $display("PASS: sum() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: sum() = %0d, expected 15", result);
            fail_count++;
        end

        // Test 2: product
        result = arr.product();
        if (result == 120) begin
            $display("PASS: product() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: product() = %0d, expected 120", result);
            fail_count++;
        end

        // Test 3: and reduction
        bit_result = bits.and();
        if (bit_result == 4'b0000) begin
            $display("PASS: and() = %04b", bit_result);
            pass_count++;
        end else begin
            $display("FAIL: and() = %04b, expected 0000", bit_result);
            fail_count++;
        end

        // Test 4: or reduction
        bit_result = bits.or();
        if (bit_result == 4'b1111) begin
            $display("PASS: or() = %04b", bit_result);
            pass_count++;
        end else begin
            $display("FAIL: or() = %04b, expected 1111", bit_result);
            fail_count++;
        end

        // Test 5: xor reduction
        bit_result = bits.xor();
        // 1111 ^ 0101 ^ 0011 ^ 1010 = 1111 ^ 0101 = 1010 ^ 0011 = 1001 ^ 1010 = 0011
        if (bit_result == 4'b0011) begin
            $display("PASS: xor() = %04b", bit_result);
            pass_count++;
        end else begin
            $display("FAIL: xor() = %04b, expected 0011", bit_result);
            fail_count++;
        end

        // Test 6: sum with expression
        result = arr.sum(x) with (x * 2);
        if (result == 30) begin
            $display("PASS: sum(x * 2) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: sum(x * 2) = %0d, expected 30", result);
            fail_count++;
        end

        $display("");
        $display("=== Array Reduction Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
