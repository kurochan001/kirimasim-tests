/*
:name: test_operators
:description: Arithmetic, logical, relational, bitwise and shift operators on 8-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 11.4.7 11.4.8 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operators.expected
*/
// IEEE 1800-2023 Chapter 11: Operators and expressions
// §11.4 Operators

module test_operators;
    int test_count;
    int pass_count;

    logic [7:0] a, b, result;
    logic [15:0] wide;
    int i, j;

    initial begin
        test_count = 0;
        pass_count = 0;

        // §11.4.3 Arithmetic operators
        a = 8'd10;
        b = 8'd3;

        // Test 1: Addition
        result = a + b;
        test_count++;
        if (result == 13) pass_count++;
        else $display("FAIL: Addition - result=%0d", result);

        // Test 2: Subtraction
        result = a - b;
        test_count++;
        if (result == 7) pass_count++;
        else $display("FAIL: Subtraction - result=%0d", result);

        // Test 3: Multiplication
        result = a * b;
        test_count++;
        if (result == 30) pass_count++;
        else $display("FAIL: Multiplication - result=%0d", result);

        // Test 4: Division
        result = a / b;
        test_count++;
        if (result == 3) pass_count++;
        else $display("FAIL: Division - result=%0d", result);

        // Test 5: Modulus
        result = a % b;
        test_count++;
        if (result == 1) pass_count++;
        else $display("FAIL: Modulus - result=%0d", result);

        // §11.4.7 Logical operators
        a = 8'd5;
        b = 8'd0;

        // Test 6: Logical AND
        test_count++;
        if ((a && b) == 0) pass_count++;
        else $display("FAIL: Logical AND - result=%0d", a && b);

        // Test 7: Logical OR
        test_count++;
        if ((a || b) == 1) pass_count++;
        else $display("FAIL: Logical OR - result=%0d", a || b);

        // Test 8: Logical NOT
        test_count++;
        if ((!b) == 1) pass_count++;
        else $display("FAIL: Logical NOT - result=%0d", !b);

        // §11.4.4 Relational operators
        a = 8'd10;
        b = 8'd20;

        // Test 9: Less than
        test_count++;
        if ((a < b) == 1) pass_count++;
        else $display("FAIL: Less than");

        // Test 10: Greater than
        test_count++;
        if ((a > b) == 0) pass_count++;
        else $display("FAIL: Greater than");

        // §11.4.8 Bitwise operators
        a = 8'b10101010;
        b = 8'b11001100;

        // Test 11: Bitwise AND
        result = a & b;
        test_count++;
        if (result == 8'b10001000) pass_count++;
        else $display("FAIL: Bitwise AND - result=0x%0h", result);

        // Test 12: Bitwise OR
        result = a | b;
        test_count++;
        if (result == 8'b11101110) pass_count++;
        else $display("FAIL: Bitwise OR - result=0x%0h", result);

        // Test 13: Bitwise XOR
        result = a ^ b;
        test_count++;
        if (result == 8'b01100110) pass_count++;
        else $display("FAIL: Bitwise XOR - result=0x%0h", result);

        // §11.4.10 Shift operators
        a = 8'b00001111;

        // Test 14: Left shift
        result = a << 2;
        test_count++;
        if (result == 8'b00111100) pass_count++;
        else $display("FAIL: Left shift - result=0x%0h", result);

        // Test 15: Right shift
        result = a >> 2;
        test_count++;
        if (result == 8'b00000011) pass_count++;
        else $display("FAIL: Right shift - result=0x%0h", result);

        $display("Chapter 11.4 Operators: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
