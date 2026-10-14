/*
:name: test_bit_ops
:description: Test for bit operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_ops.expected
*/
// Test for bit operations
// IEEE 1800-2023 §11.4

module test_bit_ops;
    logic [7:0] a, b, result;
    logic [15:0] wide;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Bitwise AND
        test_count++;
        a = 8'hAA;
        b = 8'h55;
        result = a & b;
        if (result == 8'h00) begin
            $display("Test 1: Bitwise AND PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Bitwise OR
        test_count++;
        result = a | b;
        if (result == 8'hFF) begin
            $display("Test 2: Bitwise OR PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Bitwise XOR
        test_count++;
        a = 8'hF0;
        b = 8'h0F;
        result = a ^ b;
        if (result == 8'hFF) begin
            $display("Test 3: Bitwise XOR PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Bitwise NOT
        test_count++;
        a = 8'hAA;
        result = ~a;
        if (result == 8'h55) begin
            $display("Test 4: Bitwise NOT PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Left shift
        test_count++;
        a = 8'h01;
        result = a << 4;
        if (result == 8'h10) begin
            $display("Test 5: Left shift PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: Right shift
        test_count++;
        a = 8'h80;
        result = a >> 4;
        if (result == 8'h08) begin
            $display("Test 6: Right shift PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
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
