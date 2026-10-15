/*
:name: test_onehot_isunknown
:description: Bit vector system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_onehot_isunknown.expected
*/
// IEEE 1800-2023 Section 20.9 - Bit vector system functions
// Tests $onehot, $onehot0, $isunknown corner cases

module test_onehot_isunknown;
    logic [7:0] vec;
    logic [3:0] small_vec;
    logic result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("IEEE 1800-2023 Section 20.9 - Bit Vector System Functions Test");
        $display("============================================================");

        // Test 1: $onehot with exactly one bit set
        vec = 8'b0000_0001;
        result = $onehot(vec);
        if (result == 1) begin
            $display("PASS: Test 1 - $onehot(8'b00000001) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - $onehot(8'b00000001) expected 1, got %0d", result);
            fail_count++;
        end

        // Test 2: $onehot with zero bits set (should be 0)
        vec = 8'b0000_0000;
        result = $onehot(vec);
        if (result == 0) begin
            $display("PASS: Test 2 - $onehot(8'b00000000) = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - $onehot(8'b00000000) expected 0, got %0d", result);
            fail_count++;
        end

        // Test 3: $onehot with multiple bits set (should be 0)
        vec = 8'b0000_0011;
        result = $onehot(vec);
        if (result == 0) begin
            $display("PASS: Test 3 - $onehot(8'b00000011) = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - $onehot(8'b00000011) expected 0, got %0d", result);
            fail_count++;
        end

        // Test 4: $onehot0 with zero bits set (should be 1)
        vec = 8'b0000_0000;
        result = $onehot0(vec);
        if (result == 1) begin
            $display("PASS: Test 4 - $onehot0(8'b00000000) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - $onehot0(8'b00000000) expected 1, got %0d", result);
            fail_count++;
        end

        // Test 5: $onehot0 with one bit set (should be 1)
        vec = 8'b0001_0000;
        result = $onehot0(vec);
        if (result == 1) begin
            $display("PASS: Test 5 - $onehot0(8'b00010000) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - $onehot0(8'b00010000) expected 1, got %0d", result);
            fail_count++;
        end

        // Test 6: $onehot0 with multiple bits set (should be 0)
        vec = 8'b0001_0001;
        result = $onehot0(vec);
        if (result == 0) begin
            $display("PASS: Test 6 - $onehot0(8'b00010001) = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - $onehot0(8'b00010001) expected 0, got %0d", result);
            fail_count++;
        end

        // Test 7: $isunknown with no X/Z (should be 0)
        vec = 8'b1010_1010;
        result = $isunknown(vec);
        if (result == 0) begin
            $display("PASS: Test 7 - $isunknown(8'b10101010) = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - $isunknown(8'b10101010) expected 0, got %0d", result);
            fail_count++;
        end

        // Test 8: $isunknown with X bit (should be 1)
        vec = 8'bxxxx_0000;
        result = $isunknown(vec);
        if (result == 1) begin
            $display("PASS: Test 8 - $isunknown(8'bxxxx0000) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 8 - $isunknown(8'bxxxx0000) expected 1, got %0d", result);
            fail_count++;
        end

        // Test 9: $isunknown with Z bit (should be 1)
        vec = 8'b0000_zzzz;
        result = $isunknown(vec);
        if (result == 1) begin
            $display("PASS: Test 9 - $isunknown(8'b0000zzzz) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 9 - $isunknown(8'b0000zzzz) expected 1, got %0d", result);
            fail_count++;
        end

        // Test 10: $onehot with high bit set
        vec = 8'b1000_0000;
        result = $onehot(vec);
        if (result == 1) begin
            $display("PASS: Test 10 - $onehot(8'b10000000) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 10 - $onehot(8'b10000000) expected 1, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("============================================================");
        $display("Test Summary: %0d passed, %0d failed", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end

        $finish;
    end
endmodule
