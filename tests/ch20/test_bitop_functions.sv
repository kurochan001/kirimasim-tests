/*
:name: test_bitop_functions
:description: Test for bit operation system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 20.8.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bitop_functions.expected
*/
// Test for bit operation system functions
// IEEE 1800-2023 §20.9

module test_bitop_functions;
    logic [7:0] data;
    int result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test $onehot - exactly one bit set
        test_count++;
        data = 8'b00000001;
        if ($onehot(data)) begin
            $display("Test 1: $onehot(00000001) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1: $onehot(00000001) = 0 FAIL");
        end

        test_count++;
        data = 8'b00010000;
        if ($onehot(data)) begin
            $display("Test 2: $onehot(00010000) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 2: $onehot(00010000) = 0 FAIL");
        end

        test_count++;
        data = 8'b00000011;  // Two bits set
        if (!$onehot(data)) begin
            $display("Test 3: $onehot(00000011) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 3: $onehot(00000011) = 1 FAIL");
        end

        test_count++;
        data = 8'b00000000;  // No bits set
        if (!$onehot(data)) begin
            $display("Test 4: $onehot(00000000) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 4: $onehot(00000000) = 1 FAIL");
        end

        // Test $onehot0 - zero or one bit set
        test_count++;
        data = 8'b00000000;
        if ($onehot0(data)) begin
            $display("Test 5: $onehot0(00000000) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 5: $onehot0(00000000) = 0 FAIL");
        end

        test_count++;
        data = 8'b00000001;
        if ($onehot0(data)) begin
            $display("Test 6: $onehot0(00000001) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 6: $onehot0(00000001) = 0 FAIL");
        end

        test_count++;
        data = 8'b00000011;
        if (!$onehot0(data)) begin
            $display("Test 7: $onehot0(00000011) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 7: $onehot0(00000011) = 1 FAIL");
        end

        // Test $countones
        test_count++;
        data = 8'b00000000;
        result = $countones(data);
        if (result == 0) begin
            $display("Test 8: $countones(00000000) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 8: $countones(00000000) = %0d FAIL", result);
        end

        test_count++;
        data = 8'b11111111;
        result = $countones(data);
        if (result == 8) begin
            $display("Test 9: $countones(11111111) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 9: $countones(11111111) = %0d FAIL", result);
        end

        test_count++;
        data = 8'b10101010;
        result = $countones(data);
        if (result == 4) begin
            $display("Test 10: $countones(10101010) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 10: $countones(10101010) = %0d FAIL", result);
        end

        // Test $clog2
        test_count++;
        result = $clog2(1);
        if (result == 0) begin
            $display("Test 11: $clog2(1) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 11: $clog2(1) = %0d FAIL", result);
        end

        test_count++;
        result = $clog2(8);
        if (result == 3) begin
            $display("Test 12: $clog2(8) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 12: $clog2(8) = %0d FAIL", result);
        end

        test_count++;
        result = $clog2(9);
        if (result == 4) begin
            $display("Test 13: $clog2(9) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 13: $clog2(9) = %0d FAIL", result);
        end

        // Test $isunknown
        test_count++;
        data = 8'b00000000;
        if (!$isunknown(data)) begin
            $display("Test 14: $isunknown(00000000) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 14: $isunknown(00000000) = 1 FAIL");
        end

        test_count++;
        data = 8'bxxxxxxxx;
        if ($isunknown(data)) begin
            $display("Test 15: $isunknown(xxxxxxxx) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 15: $isunknown(xxxxxxxx) = 0 FAIL");
        end

        test_count++;
        data = 8'b0000000x;
        if ($isunknown(data)) begin
            $display("Test 16: $isunknown(0000000x) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 16: $isunknown(0000000x) = 0 FAIL");
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
