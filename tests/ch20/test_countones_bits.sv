/*
:name: test_countones_bits
:description: Test for $countones and $countbits functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countones_bits.expected
*/
// Test for $countones and $countbits functions
// IEEE 1800-2023 Section 20.9

module test_countones_bits;
    logic [7:0] test_vec;
    int result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: $countones with no bits set
        test_count++;
        test_vec = 8'b0000_0000;
        result = $countones(test_vec);
        if (result == 0) begin
            $display("Test 1: $countones(8'b00000000) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%0d", result);
        end

        // Test 2: $countones with all bits set
        test_count++;
        test_vec = 8'b1111_1111;
        result = $countones(test_vec);
        if (result == 8) begin
            $display("Test 2: $countones(8'b11111111) = 8 PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%0d", result);
        end

        // Test 3: $countones with some bits set
        test_count++;
        test_vec = 8'b1010_1010;
        result = $countones(test_vec);
        if (result == 4) begin
            $display("Test 3: $countones(8'b10101010) = 4 PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL result=%0d", result);
        end

        // Test 4: $countones with one bit set
        test_count++;
        test_vec = 8'b0000_0001;
        result = $countones(test_vec);
        if (result == 1) begin
            $display("Test 4: $countones(8'b00000001) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL result=%0d", result);
        end

        // Test 5: $countones with integer
        test_count++;
        result = $countones(255);  // All 8 bits set in lowest byte
        if (result == 8) begin
            $display("Test 5: $countones(255) = 8 PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL result=%0d", result);
        end

        // Test 6: $countbits counting zeros
        test_count++;
        test_vec = 8'b1111_0000;
        result = $countbits(test_vec, 0);
        if (result == 4) begin
            $display("Test 6: $countbits(8'b11110000, 0) = 4 PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL result=%0d", result);
        end

        // Test 7: $countbits counting ones
        test_count++;
        test_vec = 8'b1111_0000;
        result = $countbits(test_vec, 1);
        if (result == 4) begin
            $display("Test 7: $countbits(8'b11110000, 1) = 4 PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL result=%0d", result);
        end

        // Test 8: $countbits with all zeros
        test_count++;
        test_vec = 8'b0000_0000;
        result = $countbits(test_vec, 0);
        if (result == 8) begin
            $display("Test 8: $countbits(8'b00000000, 0) = 8 PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL result=%0d", result);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
