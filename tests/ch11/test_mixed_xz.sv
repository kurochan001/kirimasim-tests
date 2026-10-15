/*
:name: test_mixed_xz
:description: Bitwise, arithmetic, equality and reduction operators on x and z bits
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 11.4.5 11.4.8 11.4.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_mixed_xz.expected
*/
// Bitwise, arithmetic, equality and reduction operators on x and z bits
module test_mixed_xz;
    int pass_count = 0;
    int total_tests = 10;

    // Test variables
    logic [7:0] a, b, result;
    logic [15:0] wide_result;
    logic single_bit;
    logic [3:0] nibble;

    initial begin
        // Test 1: X and Z in same value
        a = 8'bxxxx_zzzz;
        if (a[7:4] === 4'bxxxx && a[3:0] === 4'bzzzz) begin
            $display("PASS: Mixed X and Z stored correctly");
            pass_count++;
        end else begin
            $display("FAIL: Mixed X and Z storage failed");
        end

        // Test 2: X AND Z
        a = 8'bxxxxxxxx;
        b = 8'bzzzzzzzz;
        result = a & b;
        // z acts as x in these operators, and any x or z bit in an
        // arithmetic operand makes the whole result x (11.4.8, 11.4.2).
        if (result === 8'bx) begin
            $display("PASS: X AND Z gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: X AND Z gave (result=0x%h)", result);
        end

        // Test 3: X OR Z
        a = 8'bxxxxxxxx;
        b = 8'bzzzzzzzz;
        result = a | b;
        if (result === 8'bx) begin
            $display("PASS: X OR Z gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: X OR Z gave (result=0x%h)", result);
        end

        // Test 4: X XOR Z
        a = 8'bxxxxxxxx;
        b = 8'bzzzzzzzz;
        result = a ^ b;
        if (result === 8'bx) begin
            $display("PASS: X XOR Z gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: X XOR Z gave (result=0x%h)", result);
        end

        // Test 5: Mixed pattern arithmetic
        a = 8'bxz_xz_xz_xz;
        b = 8'h01;
        result = a + b;
        if (result === 8'bx) begin
            $display("PASS: Alternating XZ arithmetic gives x (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: Alternating XZ arithmetic gave (result=0x%h)", result);
        end

        // Test 6: Concatenate X and Z patterns
        a = 8'bxxxxxxxx;
        b = 8'bzzzzzzzz;
        wide_result = {a, b};
        if (wide_result[15:8] === 8'bxxxxxxxx && wide_result[7:0] === 8'bzzzzzzzz) begin
            $display("PASS: Concatenate X and Z preserves distinction");
            pass_count++;
        end else begin
            $display("FAIL: XZ concatenation (result=0x%h)", wide_result);
        end

        // Test 7: Comparison of X and Z
        a = 8'bxxxxxxxx;
        b = 8'bzzzzzzzz;
        // Unknown bits make the equality x (11.4.5).
        if ((a == b) === 1'bx) begin
            $display("PASS: Logical equality X==Z is x");
            pass_count++;
        end else begin
            $display("FAIL: Logical equality X==Z = %b", a == b);
        end

        // Test 8: Case inequality of X and Z
        a = 8'bxxxxxxxx;
        b = 8'bzzzzzzzz;
        if (a !== b) begin
            $display("PASS: Case inequality X!==Z is true");
            pass_count++;
        end else begin
            $display("FAIL: Case inequality should distinguish X and Z");
        end

        // Test 9: Mixed XZ in reduction
        a = 8'bxxzz1100;
        single_bit = |a;  // reduction OR
        // 1|anything = 1
        if (single_bit === 1'b1) begin
            $display("PASS: Reduction OR with XZ and 1 gives 1");
            pass_count++;
        end else begin
            $display("FAIL: Reduction OR with XZ (result=%b)", single_bit);
        end

        // Test 10: Bit select from mixed XZ
        a = 8'bxzxz_1010;
        nibble = a[7:4];
        if (nibble === 4'bxzxz) begin
            $display("PASS: Bit select preserves mixed XZ");
            pass_count++;
        end else begin
            $display("FAIL: Bit select mixed XZ (nibble=%b)", nibble);
        end

        $display("PASS: mixed_xz (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
