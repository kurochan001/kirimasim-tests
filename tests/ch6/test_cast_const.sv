/*
:name: test_cast_const
:description: Const cast operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_const.expected
*/
// Const cast operations
module test_cast_const;
    localparam int PARAM_VAL = 42;
    localparam logic [7:0] PARAM_BYTE = 8'hAB;

    logic [31:0] result;
    logic [7:0] byte_result;
    int int_result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Cast literal to specific width
        result = 32'(8'hFF);
        if (result == 32'h000000FF) begin
            $display("PASS: Test 1 - Literal width cast");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x000000FF, got 0x%h", result);
            fail_count++;
        end

        // Test 2: Cast parameter to different width
        result = 32'(PARAM_BYTE);
        if (result == 32'h000000AB) begin
            $display("PASS: Test 2 - Parameter width cast");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0x000000AB, got 0x%h", result);
            fail_count++;
        end

        // Test 3: Signed cast of unsigned literal
        int_result = signed'(8'hFF);
        if (int_result == -1) begin
            $display("PASS: Test 3 - Signed cast of literal");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected -1, got %0d", int_result);
            fail_count++;
        end

        // Test 4: Cast expression result
        result = 32'(PARAM_BYTE + 8'h55);
        if (result == 32'h00000100) begin
            $display("PASS: Test 4 - Cast of expression");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0x00000100, got 0x%h", result);
            fail_count++;
        end

        // Test 5: Const cast in array index (compile-time evaluation)
        begin
            logic [3:0] arr [8];
            int idx;
            arr[0] = 4'hA;
            arr[1] = 4'hB;
            arr[2] = 4'hC;
            idx = 2;
            byte_result = arr[int'(idx)];
            if (byte_result == 4'hC) begin
                $display("PASS: Test 5 - Cast in array index");
                pass_count++;
            end else begin
                $display("FAIL: Test 5 - Expected 0xC, got 0x%h", byte_result);
                fail_count++;
            end
        end

        // Summary
        $display("Cast Const: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
