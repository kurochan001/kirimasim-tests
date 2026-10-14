/*
:name: test_value_ops
:description: Test for value operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_ops.expected
*/
// Test for value operations
// IEEE 1800-2023 §11

module test_value_ops;
    logic [31:0] a, b, result;
    logic [7:0] byte_val;
    logic signed [31:0] sa, sb;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Bitwise AND
        test_count++;
        a = 32'hFF00FF00;
        b = 32'h0F0F0F0F;
        result = a & b;
        if (result == 32'h0F000F00) begin
            $display("Test 1: Bitwise AND PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%h", result);
        end

        // Test 2: Bitwise OR
        test_count++;
        result = a | b;
        if (result == 32'hFF0FFF0F) begin
            $display("Test 2: Bitwise OR PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%h", result);
        end

        // Test 3: Bitwise XOR
        test_count++;
        result = a ^ b;
        if (result == 32'hF00FF00F) begin
            $display("Test 3: Bitwise XOR PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL result=%h", result);
        end

        // Test 4: Shift left
        test_count++;
        a = 32'h00000001;
        result = a << 4;
        if (result == 32'h00000010) begin
            $display("Test 4: Shift left PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL result=%h", result);
        end

        // Test 5: Shift right
        test_count++;
        a = 32'h00000100;
        result = a >> 4;
        if (result == 32'h00000010) begin
            $display("Test 5: Shift right PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL result=%h", result);
        end

        // Test 6: Arithmetic shift right
        test_count++;
        sa = -16;
        sb = sa >>> 2;
        if (sb == -4) begin
            $display("Test 6: Arithmetic shift PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL sb=%0d", sb);
        end

        // Test 7: Concatenation
        test_count++;
        byte_val = 8'hAB;
        result = {24'h0, byte_val};
        if (result == 32'h000000AB) begin
            $display("Test 7: Concatenation PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL result=%h", result);
        end

        // Test 8: Replication
        test_count++;
        result = {4{8'hAB}};
        if (result == 32'hABABABAB) begin
            $display("Test 8: Replication PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL result=%h", result);
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
