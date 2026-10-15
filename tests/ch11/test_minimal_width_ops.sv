/*
:name: test_minimal_width_ops
:description: Arithmetic, shift and concatenation on 1-bit and 2-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1 10.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_minimal_width_ops.expected
*/
// Arithmetic, shift and concatenation on 1-bit and 2-bit values
module test_minimal_width_ops;
    int pass_count = 0;
    int total_tests = 10;

    // Test variables - using minimal practical widths
    logic [0:0] one_bit_a, one_bit_b, one_bit_result;
    logic [1:0] two_bit;
    logic [7:0] byte_val;
    logic single_wire;

    initial begin
        // Test 1: Single bit operations
        one_bit_a = 1'b1;
        one_bit_b = 1'b1;
        one_bit_result = one_bit_a & one_bit_b;
        if (one_bit_result == 1'b1) begin
            $display("PASS: Single bit AND");
            pass_count++;
        end else begin
            $display("FAIL: Single bit AND: expected 1, got %b", one_bit_result);
        end

        // Test 2: Single bit addition (overflow)
        one_bit_a = 1'b1;
        one_bit_b = 1'b1;
        one_bit_result = one_bit_a + one_bit_b;
        if (one_bit_result == 1'b0) begin
            $display("PASS: Single bit addition overflows to 0");
            pass_count++;
        end else begin
            $display("FAIL: Single bit add: expected 0, got %b", one_bit_result);
        end

        // Test 3: Single bit increment
        one_bit_a = 1'b0;
        one_bit_a = one_bit_a + 1;
        if (one_bit_a == 1'b1) begin
            $display("PASS: Single bit increment 0->1");
            pass_count++;
        end else begin
            $display("FAIL: Single bit incr: expected 1, got %b", one_bit_a);
        end

        // Test 4: Two-bit max value
        two_bit = 2'b11;
        two_bit = two_bit + 1;
        if (two_bit == 2'b00) begin
            $display("PASS: Two-bit overflow wraps");
            pass_count++;
        end else begin
            $display("FAIL: Two-bit overflow: expected 00, got %b", two_bit);
        end

        // Test 5: Single bit XOR
        one_bit_a = 1'b1;
        one_bit_b = 1'b0;
        one_bit_result = one_bit_a ^ one_bit_b;
        if (one_bit_result == 1'b1) begin
            $display("PASS: Single bit XOR");
            pass_count++;
        end else begin
            $display("FAIL: Single bit XOR: expected 1, got %b", one_bit_result);
        end

        // Test 6: Single bit shift
        one_bit_a = 1'b1;
        one_bit_result = one_bit_a << 1;
        if (one_bit_result == 1'b0) begin
            $display("PASS: Single bit shift left produces 0");
            pass_count++;
        end else begin
            $display("FAIL: Single bit shift: expected 0, got %b", one_bit_result);
        end

        // Test 7: Extract single bit from byte
        byte_val = 8'b10101010;
        single_wire = byte_val[3];
        if (single_wire == 1'b1) begin
            $display("PASS: Extract single bit");
            pass_count++;
        end else begin
            $display("FAIL: Extract bit: expected 1, got %b", single_wire);
        end

        // Test 8: Assign single bit to byte
        byte_val = 8'h00;
        single_wire = 1'b1;
        byte_val[4] = single_wire;
        if (byte_val == 8'h10) begin
            $display("PASS: Assign single bit to byte");
            pass_count++;
        end else begin
            $display("FAIL: Assign bit: expected 0x10, got 0x%h", byte_val);
        end

        // Test 9: Single bit reduction
        one_bit_a = 1'b1;
        one_bit_result = |one_bit_a;
        if (one_bit_result == 1'b1) begin
            $display("PASS: Single bit reduction OR");
            pass_count++;
        end else begin
            $display("FAIL: Single bit reduction: expected 1, got %b", one_bit_result);
        end

        // Test 10: Single bit concatenation
        one_bit_a = 1'b1;
        one_bit_b = 1'b0;
        two_bit = {one_bit_a, one_bit_b};
        if (two_bit == 2'b10) begin
            $display("PASS: Single bit concatenation");
            pass_count++;
        end else begin
            $display("FAIL: Single bit concat: expected 10, got %b", two_bit);
        end

        $display("PASS: zero_width (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
