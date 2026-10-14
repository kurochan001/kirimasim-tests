/*
:name: test_z_propagation
:description: Z value propagation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 11.4.6 11.4.8 11.4.10 11.4.11
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_z_propagation.expected
*/
// Z value propagation edge cases
module test_z_propagation;
    int pass_count = 0;
    int total_tests = 12;

    // Test variables
    logic [7:0] a, b, result;
    logic [31:0] wide_a, wide_result;
    logic single_bit;
    logic [3:0] nibble;

    initial begin
        // Test 1: Z in addition: a z operand bit makes the whole result x (11.4.2)
        a = 8'bzzzz0000;
        b = 8'h01;
        result = a + b;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 1 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 (result=%b)", result);
        end

        // Test 2: Z in AND acts like x: 1&z is x, 0&z is 0 (11.4.8)
        a = 8'b10101010;
        b = 8'bzzzz0000;
        result = a & b;
        if (result === 8'bx0x00000) begin
            $display("PASS: Test 2 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 (result=%b)", result);
        end

        // Test 3: Z in OR: 0|z is x, 1|z is 1 (11.4.8)
        a = 8'b00001111;
        b = 8'bzzzz0000;
        result = a | b;
        if (result === 8'bxxxx1111) begin
            $display("PASS: Test 3 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 (result=%b)", result);
        end

        // Test 4: Z in XOR gives x (11.4.8)
        a = 8'b11110000;
        b = 8'bzzzz1111;
        result = a ^ b;
        if (result === 8'bxxxx1111) begin
            $display("PASS: Test 4 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 (result=%b)", result);
        end

        // Test 5: All-z operand in addition (11.4.2)
        a = 8'bzzzzzzzz;
        b = 8'hFF;
        result = a + b;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 5 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 (result=%b)", result);
        end

        // Test 6: Case equality with z (11.4.6)
        a = 8'bzzzz0000;
        if (a === 8'bzzzz0000) begin
            $display("PASS: Test 6 (a=%b)", a);
            pass_count++;
        end else begin
            $display("FAIL: Test 6 (a=%b)", a);
        end

        // Test 7: Z condition acts like x and merges both results; AA and 55 differ in every bit (11.4.11)
        single_bit = 1'bz;
        result = single_bit ? 8'hAA : 8'h55;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 7 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 7 (result=%b)", result);
        end

        // Test 8: Z in shift: z bits move unchanged, zeros fill (11.4.10)
        a = 8'bzzzzzz01;
        result = a << 2;
        if (result === 8'bzzzz0100) begin
            $display("PASS: Test 8 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 8 (result=%b)", result);
        end

        // Test 9: Z in multiplication (11.4.2)
        a = 8'bzzzz1111;
        b = 8'h02;
        result = a * b;
        if (result === 8'bxxxxxxxx) begin
            $display("PASS: Test 9 (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 9 (result=%b)", result);
        end

        // Test 10: Z part select
        wide_a = 32'hzzzzzzzz;
        nibble = wide_a[7:4];
        if (nibble === 4'bzzzz) begin
            $display("PASS: Test 10 (nibble=%b)", nibble);
            pass_count++;
        end else begin
            $display("FAIL: Test 10 (nibble=%b)", nibble);
        end

        // Test 11: Z in concatenation
        a = 8'bzzzz0000;
        b = 8'h0F;
        wide_result = {16'h0000, a, b};
        if (wide_result === 32'b0000_0000_0000_0000_zzzz_0000_0000_1111) begin
            $display("PASS: Test 11 (wide_result=%b)", wide_result);
            pass_count++;
        end else begin
            $display("FAIL: Test 11 (wide_result=%b)", wide_result);
        end

        // Test 12: z and x are different values for case equality (11.4.6)
        a = 8'bzzzz0000;
        b = 8'bxxxx0000;
        if (a !== b) begin
            $display("PASS: Test 12 (z and x are distinct)");
            pass_count++;
        end else begin
            $display("FAIL: Test 12 (z and x compared equal)");
        end

        $display("z_propagation: %0d/%0d", pass_count, total_tests);
        if (pass_count == total_tests) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end
endmodule
