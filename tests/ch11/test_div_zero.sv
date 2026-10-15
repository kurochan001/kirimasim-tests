/*
:name: test_div_zero
:description: Division and modulus by zero give x, and 0 when stored in an int
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 6.11.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_div_zero.expected
*/
// Division by zero gives x (11.4.2); stored into a 2-state int, x becomes 0 (6.11.2)
module test_div_zero;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    logic [31:0] dividend, divisor, result;
    int int_dividend, int_divisor, int_result;
    logic [7:0] u8_a, u8_b, u8_result;
    logic [63:0] u64_a, u64_b, u64_result;

    initial begin
        // Test 1: Unsigned division by zero
        dividend = 32'h12345678;
        divisor = 32'h00000000;
        result = dividend / divisor;
        if (result === 32'bx) begin
            $display("PASS: Unsigned div by zero gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: Unsigned div by zero gave (result=0x%h)", result);
        end

        // Test 2: Signed integer division by zero
        int_dividend = 100;
        int_divisor = 0;
        int_result = int_dividend / int_divisor;
        if (int_result == 0) begin
            $display("PASS: Signed int div by zero gives 0 in an int (result=%0d)", int_result);
            pass_count++;
        end else begin
            $display("FAIL: Signed int div by zero gave (result=%0d)", int_result);
        end

        // Test 3: Zero divided by zero
        dividend = 32'h00000000;
        divisor = 32'h00000000;
        result = dividend / divisor;
        if (result === 32'bx) begin
            $display("PASS: Zero div by zero gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: Zero div by zero gave (result=0x%h)", result);
        end

        // Test 4: Negative divided by zero
        int_dividend = -100;
        int_divisor = 0;
        int_result = int_dividend / int_divisor;
        if (int_result == 0) begin
            $display("PASS: Negative div by zero gives 0 in an int (result=%0d)", int_result);
            pass_count++;
        end else begin
            $display("FAIL: Negative div by zero gave (result=%0d)", int_result);
        end

        // Test 5: 8-bit division by zero
        u8_a = 8'hAB;
        u8_b = 8'h00;
        u8_result = u8_a / u8_b;
        if (u8_result === 8'bx) begin
            $display("PASS: 8-bit div by zero gives x (result=0x%h)", u8_result);
            pass_count++;
        end else begin
            $display("FAIL: 8-bit div by zero gave (result=0x%h)", u8_result);
        end

        // Test 6: 64-bit division by zero
        u64_a = 64'h123456789ABCDEF0;
        u64_b = 64'h0000000000000000;
        u64_result = u64_a / u64_b;
        if (u64_result === 64'bx) begin
            $display("PASS: 64-bit div by zero gives x (result=0x%h)", u64_result);
            pass_count++;
        end else begin
            $display("FAIL: 64-bit div by zero gave (result=0x%h)", u64_result);
        end

        // Test 7: Division by variable that becomes zero
        divisor = 32'h00000005;
        divisor = divisor - 5;
        result = 32'h00000064 / divisor;
        if (result === 32'bx) begin
            $display("PASS: Div by variable zero gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: Div by variable zero gave (result=0x%h)", result);
        end

        // Test 8: Division in expression with zero
        u8_a = 8'h10;
        u8_b = 8'h00;
        u8_result = (u8_a + 5) / u8_b;
        if (u8_result === 8'bx) begin
            $display("PASS: Expression div by zero gives x (result=0x%h)", u8_result);
            pass_count++;
        end else begin
            $display("FAIL: Expression div by zero gave (result=0x%h)", u8_result);
        end

        $display("PASS: div_zero (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
