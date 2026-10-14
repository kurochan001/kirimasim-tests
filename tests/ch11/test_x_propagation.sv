/*
:name: test_x_propagation
:description: X value propagation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 11.4.8 11.4.9 11.4.10 11.4.11
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_x_propagation.expected
*/
// X value propagation edge cases
module test_x_propagation;
    int pass_count = 0;
    int total_tests = 12;

    // Test variables
    logic [7:0] a, b, result;
    logic [31:0] wide_a, wide_b, wide_result;
    logic single_bit;
    logic [3:0] nibble;

    initial begin
        // Test 1: X in addition: any x operand bit makes the whole result x (11.4.2)
        a = 8'b1010xxxx;
        b = 8'h01;
        result = a + b;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 1 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 (result=%b)", result);
        end

        // Test 2: X in AND: 1&x is x, 0&x is 0 (11.4.8)
        a = 8'b10101010;
        b = 8'bxxxx0000;
        result = a & b;
        if (result === 8'bx0x00000) begin
            $display("PASS: Test 2 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 (result=%b)", result);
        end

        // Test 3: X in OR: 0|x is x, 1|x is 1 (11.4.8)
        a = 8'b00001111;
        b = 8'bxxxx0000;
        result = a | b;
        if (result === 8'bxxxx1111) begin
            $display("PASS: Test 3 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 (result=%b)", result);
        end

        // Test 4: X in XOR (11.4.8)
        a = 8'b11110000;
        b = 8'bxxxx1111;
        result = a ^ b;
        if (result === 8'bxxxx1111) begin
            $display("PASS: Test 4 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 (result=%b)", result);
        end

        // Test 5: All-x operand in addition (11.4.2)
        a = 8'bxxxxxxxx;
        b = 8'hFF;
        result = a + b;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 5 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 (result=%b)", result);
        end

        // Test 6: Case equality with x (11.4.6)
        a = 8'bxxxx0000;
        if (a === 8'bxxxx0000) begin
            $display("PASS: Test 6 (a=%b)", a);
            pass_count++;
        end else begin
            $display("FAIL: Test 6 (a=%b)", a);
        end

        // Test 7: X condition merges both results bit by bit; AA and 55 differ in every bit (11.4.11)
        single_bit = 1'bx;
        result = single_bit ? 8'hAA : 8'h55;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 7 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 7 (result=%b)", result);
        end

        // Test 8: X in shift: x bits move, zeros fill (11.4.10)
        a = 8'bxxxxxx01;
        result = a << 2;
        if (result === 8'bxxxx0100) begin
            $display("PASS: Test 8 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 8 (result=%b)", result);
        end

        // Test 9: X in multiplication (11.4.2)
        a = 8'bxxxx1111;
        b = 8'h02;
        result = a * b;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 9 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 9 (result=%b)", result);
        end

        // Test 10: X part select
        wide_a = 32'hxxxxxxxx;
        nibble = wide_a[7:4];
        if (nibble === 4'bxxxx) begin
            $display("PASS: Test 10 (nibble=%b)", nibble);
            pass_count++;
        end else begin
            $display("FAIL: Test 10 (nibble=%b)", nibble);
        end

        // Test 11: X in concatenation
        a = 8'bxxxx0000;
        b = 8'h0F;
        wide_result = {16'h0000, a, b};
        if (wide_result === 32'b0000_0000_0000_0000_xxxx_0000_0000_1111) begin
            $display("PASS: Test 11 (wide_result=%b)", wide_result);
            pass_count++;
        end else begin
            $display("FAIL: Test 11 (wide_result=%b)", wide_result);
        end

        // Test 12: X in reduction AND: no 0 bit and some x bits give x (11.4.9)
        a = 8'bxxxx1111;
        single_bit = &a;
        if (single_bit === 1'bx) begin
            $display("PASS: Test 12 (single_bit=%b)", single_bit);
            pass_count++;
        end else begin
            $display("FAIL: Test 12 (single_bit=%b)", single_bit);
        end

        $display("x_propagation: %0d/%0d", pass_count, total_tests);
        if (pass_count == total_tests) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end
endmodule
