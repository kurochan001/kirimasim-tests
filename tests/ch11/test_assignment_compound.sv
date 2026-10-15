/*
:name: test_assignment_compound
:description: Test for compound assignment operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_compound.expected
*/
// Test for compound assignment operators
// IEEE 1800-2023 §11.4

module test_assignment_compound;
    int val;
    logic [15:0] vec;
    real r;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: += operator
        test_count++;
        val = 10;
        val += 5;
        if (val == 15) begin
            $display("Test 1: val += 5 = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 1: val += 5 = %0d FAIL", val);
        end

        // Test 2: -= operator
        test_count++;
        val = 10;
        val -= 3;
        if (val == 7) begin
            $display("Test 2: val -= 3 = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 2: val -= 3 = %0d FAIL", val);
        end

        // Test 3: *= operator
        test_count++;
        val = 4;
        val *= 5;
        if (val == 20) begin
            $display("Test 3: val *= 5 = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 3: val *= 5 = %0d FAIL", val);
        end

        // Test 4: /= operator
        test_count++;
        val = 20;
        val /= 4;
        if (val == 5) begin
            $display("Test 4: val /= 4 = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 4: val /= 4 = %0d FAIL", val);
        end

        // Test 5: %= operator
        test_count++;
        val = 17;
        val %= 5;
        if (val == 2) begin
            $display("Test 5: val %%= 5 = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 5: val %%= 5 = %0d FAIL", val);
        end

        // Test 6: &= operator
        test_count++;
        vec = 16'hFF00;
        vec &= 16'h0FF0;
        if (vec == 16'h0F00) begin
            $display("Test 6: vec &= 0x0FF0 = 0x%h PASS", vec);
            pass_count++;
        end else begin
            $display("Test 6: vec &= = 0x%h FAIL", vec);
        end

        // Test 7: |= operator
        test_count++;
        vec = 16'h0F00;
        vec |= 16'h00F0;
        if (vec == 16'h0FF0) begin
            $display("Test 7: vec |= 0x00F0 = 0x%h PASS", vec);
            pass_count++;
        end else begin
            $display("Test 7: vec |= = 0x%h FAIL", vec);
        end

        // Test 8: ^= operator
        test_count++;
        vec = 16'hFF00;
        vec ^= 16'h0F0F;
        if (vec == 16'hF00F) begin
            $display("Test 8: vec ^= 0x0F0F = 0x%h PASS", vec);
            pass_count++;
        end else begin
            $display("Test 8: vec ^= = 0x%h FAIL", vec);
        end

        // Test 9: <<= operator
        test_count++;
        vec = 16'h000F;
        vec <<= 4;
        if (vec == 16'h00F0) begin
            $display("Test 9: vec <<= 4 = 0x%h PASS", vec);
            pass_count++;
        end else begin
            $display("Test 9: vec <<= = 0x%h FAIL", vec);
        end

        // Test 10: >>= operator
        test_count++;
        vec = 16'hF000;
        vec >>= 4;
        if (vec == 16'h0F00) begin
            $display("Test 10: vec >>= 4 = 0x%h PASS", vec);
            pass_count++;
        end else begin
            $display("Test 10: vec >>= = 0x%h FAIL", vec);
        end

        // Test 11: ++ and -- operators
        test_count++;
        val = 5;
        val++;
        if (val == 6) begin
            $display("Test 11: val++ = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 11: val++ = %0d FAIL", val);
        end

        // Test 12: Decrement
        test_count++;
        val = 5;
        val--;
        if (val == 4) begin
            $display("Test 12: val-- = %0d PASS", val);
            pass_count++;
        end else begin
            $display("Test 12: val-- = %0d FAIL", val);
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
