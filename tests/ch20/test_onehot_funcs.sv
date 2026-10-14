/*
:name: test_onehot_funcs
:description: Test for $onehot and $onehot0 functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_onehot_funcs.expected
*/
// Test for $onehot and $onehot0 functions
// IEEE 1800-2023 Section 20.9

module test_onehot_funcs;
    logic [7:0] test_vec;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: $onehot with exactly one bit set
        test_count++;
        test_vec = 8'b0000_0001;
        if ($onehot(test_vec)) begin
            $display("Test 1: $onehot(8'b00000001) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: $onehot with no bits set
        test_count++;
        test_vec = 8'b0000_0000;
        if (!$onehot(test_vec)) begin
            $display("Test 2: $onehot(8'b00000000) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: $onehot with two bits set
        test_count++;
        test_vec = 8'b0000_0011;
        if (!$onehot(test_vec)) begin
            $display("Test 3: $onehot(8'b00000011) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: $onehot with high bit set
        test_count++;
        test_vec = 8'b1000_0000;
        if ($onehot(test_vec)) begin
            $display("Test 4: $onehot(8'b10000000) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: $onehot0 with no bits set
        test_count++;
        test_vec = 8'b0000_0000;
        if ($onehot0(test_vec)) begin
            $display("Test 5: $onehot0(8'b00000000) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: $onehot0 with one bit set
        test_count++;
        test_vec = 8'b0000_0100;
        if ($onehot0(test_vec)) begin
            $display("Test 6: $onehot0(8'b00000100) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
        end

        // Test 7: $onehot0 with two bits set
        test_count++;
        test_vec = 8'b0000_0101;
        if (!$onehot0(test_vec)) begin
            $display("Test 7: $onehot0(8'b00000101) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL");
        end

        // Test 8: $onehot with integer
        test_count++;
        if ($onehot(32)) begin
            $display("Test 8: $onehot(32) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL");
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
