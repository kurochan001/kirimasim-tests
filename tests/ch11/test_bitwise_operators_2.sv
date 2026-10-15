/*
:name: test_bitwise_operators_2
:description: Bitwise AND, OR, XOR, NOT, NAND, NOR and XNOR on 8-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_operators_2.expected
*/
// IEEE 1800-2023 Bitwise Operators (§11.4.8)
// Tests bitwise AND, OR, XOR, NOT

module test_bitwise_operators;
    initial begin
        logic [7:0] a, b, result;
        static int pass_count = 0;
        static int fail_count = 0;

        a = 8'b10101010;
        b = 8'b11001100;

        // Test 1: Bitwise AND
        result = a & b;
        if (result == 8'b10001000) begin
            $display("PASS: AND = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: AND = %08b, expected 10001000", result);
            fail_count++;
        end

        // Test 2: Bitwise OR
        result = a | b;
        if (result == 8'b11101110) begin
            $display("PASS: OR = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: OR = %08b, expected 11101110", result);
            fail_count++;
        end

        // Test 3: Bitwise XOR
        result = a ^ b;
        if (result == 8'b01100110) begin
            $display("PASS: XOR = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: XOR = %08b, expected 01100110", result);
            fail_count++;
        end

        // Test 4: Bitwise NOT
        result = ~a;
        if (result == 8'b01010101) begin
            $display("PASS: NOT = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: NOT = %08b, expected 01010101", result);
            fail_count++;
        end

        // Test 5: NAND (NOT AND)
        result = ~(a & b);
        if (result == 8'b01110111) begin
            $display("PASS: NAND = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: NAND = %08b, expected 01110111", result);
            fail_count++;
        end

        // Test 6: NOR (NOT OR)
        result = ~(a | b);
        if (result == 8'b00010001) begin
            $display("PASS: NOR = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: NOR = %08b, expected 00010001", result);
            fail_count++;
        end

        // Test 7: XNOR
        result = ~(a ^ b);
        if (result == 8'b10011001) begin
            $display("PASS: XNOR = %08b", result);
            pass_count++;
        end else begin
            $display("FAIL: XNOR = %08b, expected 10011001", result);
            fail_count++;
        end

        $display("");
        $display("=== Bitwise Operators Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
