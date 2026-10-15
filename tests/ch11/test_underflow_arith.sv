/*
:name: test_underflow_arith
:description: Unsigned underflow wrap-around in 8-, 32- and 64-bit arithmetic
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_underflow_arith.expected
*/
// Unsigned underflow wrap-around in 8-, 32- and 64-bit arithmetic
module test_underflow_arith;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    logic [7:0] u8_a, u8_b, u8_result;
    logic [31:0] u32_a, u32_b, u32_result;
    logic [63:0] u64_a, u64_b, u64_result;

    initial begin
        // Test 1: 8-bit underflow subtraction
        u8_a = 8'h00;
        u8_b = 8'h01;
        u8_result = u8_a - u8_b;
        if (u8_result == 8'hFF) begin
            $display("PASS: 8-bit underflow subtraction wraps to 0xFF");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit underflow subtraction: expected 0xFF, got 0x%h", u8_result);
        end

        // Test 2: 8-bit underflow with larger subtrahend
        u8_a = 8'h05;
        u8_b = 8'h10;
        u8_result = u8_a - u8_b;
        if (u8_result == 8'hF5) begin
            $display("PASS: 8-bit underflow with larger subtrahend");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit underflow larger: expected 0xF5, got 0x%h", u8_result);
        end

        // Test 3: 32-bit underflow at zero
        u32_a = 32'h00000000;
        u32_b = 32'h00000001;
        u32_result = u32_a - u32_b;
        if (u32_result == 32'hFFFFFFFF) begin
            $display("PASS: 32-bit underflow wraps to max");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit underflow: expected 0xFFFFFFFF, got 0x%h", u32_result);
        end

        // Test 4: 32-bit underflow with large subtrahend
        u32_a = 32'h00000000;
        u32_b = 32'h80000000;
        u32_result = u32_a - u32_b;
        if (u32_result == 32'h80000000) begin
            $display("PASS: 32-bit underflow with large subtrahend");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit underflow large: expected 0x80000000, got 0x%h", u32_result);
        end

        // Test 5: 64-bit underflow
        u64_a = 64'h0000000000000000;
        u64_b = 64'h0000000000000001;
        u64_result = u64_a - u64_b;
        if (u64_result == 64'hFFFFFFFFFFFFFFFF) begin
            $display("PASS: 64-bit underflow wraps to max");
            pass_count++;
        end else begin
            $display("FAIL: 64-bit underflow: expected 0xFFFFFFFFFFFFFFFF, got 0x%h", u64_result);
        end

        // Test 6: Underflow in chain subtraction
        u8_a = 8'h10;
        u8_result = u8_a - 8'h08 - 8'h10;
        if (u8_result == 8'hF8) begin
            $display("PASS: Chain underflow wraps correctly");
            pass_count++;
        end else begin
            $display("FAIL: Chain underflow: expected 0xF8, got 0x%h", u8_result);
        end

        // Test 7: Underflow with decrement
        u8_a = 8'h00;
        u8_a = u8_a - 1;
        if (u8_a == 8'hFF) begin
            $display("PASS: Decrement underflow wraps");
            pass_count++;
        end else begin
            $display("FAIL: Decrement underflow: expected 0xFF, got 0x%h", u8_a);
        end

        // Test 8: Multiple underflows
        u8_a = 8'h02;
        u8_b = 8'h03;
        u8_result = (u8_a - u8_b) - (u8_a - u8_b);
        if (u8_result == 8'h00) begin
            $display("PASS: Multiple underflows cancel out");
            pass_count++;
        end else begin
            $display("FAIL: Multiple underflows: expected 0x00, got 0x%h", u8_result);
        end

        $display("PASS: underflow_arith (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
