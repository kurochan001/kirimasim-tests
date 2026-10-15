/*
:name: test_overflow_arith
:description: Unsigned overflow wrap-around in 8-, 32- and 64-bit arithmetic
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_overflow_arith.expected
*/
// Unsigned overflow wrap-around in 8-, 32- and 64-bit arithmetic
module test_overflow_arith;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    logic [7:0] u8_a, u8_b, u8_result;
    logic [31:0] u32_a, u32_b, u32_result;
    logic [63:0] u64_a, u64_b, u64_result;

    initial begin
        // Test 1: 8-bit overflow addition
        u8_a = 8'hFF;
        u8_b = 8'h01;
        u8_result = u8_a + u8_b;
        if (u8_result == 8'h00) begin
            $display("PASS: 8-bit overflow addition wraps to 0");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit overflow addition: expected 0x00, got 0x%h", u8_result);
        end

        // Test 2: 8-bit overflow multiplication
        u8_a = 8'h10;
        u8_b = 8'h20;
        u8_result = u8_a * u8_b;
        if (u8_result == 8'h00) begin
            $display("PASS: 8-bit overflow multiplication wraps correctly");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit overflow multiplication: expected 0x00, got 0x%h", u8_result);
        end

        // Test 3: 32-bit overflow at max value
        u32_a = 32'hFFFFFFFF;
        u32_b = 32'h00000001;
        u32_result = u32_a + u32_b;
        if (u32_result == 32'h00000000) begin
            $display("PASS: 32-bit overflow wraps to 0");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit overflow: expected 0, got 0x%h", u32_result);
        end

        // Test 4: 32-bit overflow with large values
        u32_a = 32'h80000000;
        u32_b = 32'h80000000;
        u32_result = u32_a + u32_b;
        if (u32_result == 32'h00000000) begin
            $display("PASS: 32-bit large value overflow");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit large value overflow: expected 0, got 0x%h", u32_result);
        end

        // Test 5: 64-bit overflow
        u64_a = 64'hFFFFFFFFFFFFFFFF;
        u64_b = 64'h0000000000000001;
        u64_result = u64_a + u64_b;
        if (u64_result == 64'h0000000000000000) begin
            $display("PASS: 64-bit overflow wraps to 0");
            pass_count++;
        end else begin
            $display("FAIL: 64-bit overflow: expected 0, got 0x%h", u64_result);
        end

        // Test 6: Overflow in expression chain
        u8_a = 8'hF0;
        u8_b = 8'h20;
        u8_result = u8_a + u8_b + 8'h10;
        if (u8_result == 8'h20) begin
            $display("PASS: Chain overflow wraps correctly");
            pass_count++;
        end else begin
            $display("FAIL: Chain overflow: expected 0x20, got 0x%h", u8_result);
        end

        // Test 7: Overflow with increment
        u8_a = 8'hFF;
        u8_a = u8_a + 1;
        if (u8_a == 8'h00) begin
            $display("PASS: Increment overflow wraps");
            pass_count++;
        end else begin
            $display("FAIL: Increment overflow: expected 0x00, got 0x%h", u8_a);
        end

        // Test 8: Multiple overflows in single expression
        u8_a = 8'h80;
        u8_b = 8'h80;
        u8_result = (u8_a + u8_b) + (u8_a + u8_b);
        if (u8_result == 8'h00) begin
            $display("PASS: Multiple overflows in expression");
            pass_count++;
        end else begin
            $display("FAIL: Multiple overflows: expected 0x00, got 0x%h", u8_result);
        end

        $display("PASS: overflow_arith (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
