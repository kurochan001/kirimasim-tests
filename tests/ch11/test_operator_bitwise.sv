/*
:name: test_operator_bitwise
:description: Bitwise operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_bitwise.expected
*/
// Bitwise operators
module test_operator_bitwise;
    logic [7:0] a, b, result;
    logic [3:0] nibble;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Bitwise AND (&)
        a = 8'hF0;
        b = 8'h0F;
        result = a & b;
        if (result == 8'h00) begin
            $display("PASS: Test 1 - Bitwise AND");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x00, got 0x%h", result);
            fail_count++;
        end

        // Test 2: Bitwise OR (|)
        a = 8'hF0;
        b = 8'h0F;
        result = a | b;
        if (result == 8'hFF) begin
            $display("PASS: Test 2 - Bitwise OR");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0xFF, got 0x%h", result);
            fail_count++;
        end

        // Test 3: Bitwise XOR (^)
        a = 8'hAA;  // 10101010
        b = 8'h55;  // 01010101
        result = a ^ b;
        if (result == 8'hFF) begin
            $display("PASS: Test 3 - Bitwise XOR");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0xFF, got 0x%h", result);
            fail_count++;
        end

        // Test 4: Bitwise NOT (~)
        a = 8'hA5;
        result = ~a;
        if (result == 8'h5A) begin
            $display("PASS: Test 4 - Bitwise NOT");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0x5A, got 0x%h", result);
            fail_count++;
        end

        // Test 5: XNOR (~^)
        a = 8'hAA;
        b = 8'hAA;
        result = a ~^ b;
        if (result == 8'hFF) begin
            $display("PASS: Test 5 - Bitwise XNOR");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xFF, got 0x%h", result);
            fail_count++;
        end

        // Summary
        $display("Operator Bitwise: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
