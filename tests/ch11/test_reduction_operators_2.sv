/*
:name: test_reduction_operators_2
:description: Reduction operators, including both spellings of reduction XNOR
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_operators_2.expected
*/
// IEEE 1800-2023 §11.4.9 Reduction Operators
// Tests &, |, ^, ~&, ~|, ~^, ^~ reduction operators

module test_reduction_operators;
    logic [7:0] val;
    logic result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: AND reduction (&) - all bits 1
        val = 8'hFF;
        result = &val;
        if (result == 1'b1) begin
            $display("PASS: &8'hFF = 1");
            pass_count++;
        end else begin
            $display("FAIL: &8'hFF = %b, expected 1", result);
            fail_count++;
        end

        // Test 2: AND reduction (&) - not all bits 1
        val = 8'hFE;
        result = &val;
        if (result == 1'b0) begin
            $display("PASS: &8'hFE = 0");
            pass_count++;
        end else begin
            $display("FAIL: &8'hFE = %b, expected 0", result);
            fail_count++;
        end

        // Test 3: OR reduction (|) - at least one bit 1
        val = 8'h01;
        result = |val;
        if (result == 1'b1) begin
            $display("PASS: |8'h01 = 1");
            pass_count++;
        end else begin
            $display("FAIL: |8'h01 = %b, expected 1", result);
            fail_count++;
        end

        // Test 4: OR reduction (|) - all bits 0
        val = 8'h00;
        result = |val;
        if (result == 1'b0) begin
            $display("PASS: |8'h00 = 0");
            pass_count++;
        end else begin
            $display("FAIL: |8'h00 = %b, expected 0", result);
            fail_count++;
        end

        // Test 5: XOR reduction (^) - odd number of 1s
        val = 8'b00000111;  // 3 ones
        result = ^val;
        if (result == 1'b1) begin
            $display("PASS: ^8'b00000111 = 1 (odd parity)");
            pass_count++;
        end else begin
            $display("FAIL: ^8'b00000111 = %b, expected 1", result);
            fail_count++;
        end

        // Test 6: XOR reduction (^) - even number of 1s
        val = 8'b00001111;  // 4 ones
        result = ^val;
        if (result == 1'b0) begin
            $display("PASS: ^8'b00001111 = 0 (even parity)");
            pass_count++;
        end else begin
            $display("FAIL: ^8'b00001111 = %b, expected 0", result);
            fail_count++;
        end

        // Test 7: NAND reduction (~&)
        val = 8'hFF;
        result = ~&val;
        if (result == 1'b0) begin
            $display("PASS: ~&8'hFF = 0");
            pass_count++;
        end else begin
            $display("FAIL: ~&8'hFF = %b, expected 0", result);
            fail_count++;
        end

        // Test 8: NOR reduction (~|)
        val = 8'h00;
        result = ~|val;
        if (result == 1'b1) begin
            $display("PASS: ~|8'h00 = 1");
            pass_count++;
        end else begin
            $display("FAIL: ~|8'h00 = %b, expected 1", result);
            fail_count++;
        end

        // Test 9: XNOR reduction (~^)
        val = 8'b00000111;  // 3 ones - odd
        result = ~^val;
        if (result == 1'b0) begin
            $display("PASS: ~^8'b00000111 = 0");
            pass_count++;
        end else begin
            $display("FAIL: ~^8'b00000111 = %b, expected 0", result);
            fail_count++;
        end

        // Test 10: XNOR reduction (^~) - alternative syntax
        val = 8'b00001111;  // 4 ones - even
        result = ^~val;
        if (result == 1'b1) begin
            $display("PASS: ^~8'b00001111 = 1");
            pass_count++;
        end else begin
            $display("FAIL: ^~8'b00001111 = %b, expected 1", result);
            fail_count++;
        end

        $display("");
        $display("=== Reduction Operators Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
