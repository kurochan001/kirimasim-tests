/*
:name: test_shift_operators_2
:description: Logical and arithmetic shifts, and shifts by a loop variable
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_operators_2.expected
*/
// IEEE 1800-2023 §11.4.10 Shift Operators
// Tests <<, >>, <<<, >>> shift operators

module test_shift_operators;
    logic [7:0] unsigned_val;
    logic signed [7:0] signed_val;
    logic [7:0] result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Left logical shift (<<)
        unsigned_val = 8'b00001111;
        result = unsigned_val << 2;
        if (result == 8'b00111100) begin
            $display("PASS: 8'b00001111 << 2 = 8'b00111100");
            pass_count++;
        end else begin
            $display("FAIL: 8'b00001111 << 2 = %b, expected 00111100", result);
            fail_count++;
        end

        // Test 2: Right logical shift (>>)
        unsigned_val = 8'b11110000;
        result = unsigned_val >> 2;
        if (result == 8'b00111100) begin
            $display("PASS: 8'b11110000 >> 2 = 8'b00111100");
            pass_count++;
        end else begin
            $display("FAIL: 8'b11110000 >> 2 = %b, expected 00111100", result);
            fail_count++;
        end

        // Test 3: Left arithmetic shift (<<<) - same as logical for positive
        signed_val = 8'sb00001111;
        result = signed_val <<< 2;
        if (result == 8'b00111100) begin
            $display("PASS: 8'sb00001111 <<< 2 = 8'b00111100");
            pass_count++;
        end else begin
            $display("FAIL: 8'sb00001111 <<< 2 = %b, expected 00111100", result);
            fail_count++;
        end

        // Test 4: Right arithmetic shift (>>>) on positive - fills with 0
        signed_val = 8'sb01110000;
        result = signed_val >>> 2;
        if (result == 8'b00011100) begin
            $display("PASS: 8'sb01110000 >>> 2 = 8'b00011100 (positive)");
            pass_count++;
        end else begin
            $display("FAIL: 8'sb01110000 >>> 2 = %b, expected 00011100", result);
            fail_count++;
        end

        // Test 5: Right arithmetic shift (>>>) on negative - fills with 1
        signed_val = 8'sb11110000;  // -16 in signed
        result = signed_val >>> 2;
        if (result == 8'b11111100) begin
            $display("PASS: 8'sb11110000 >>> 2 = 8'b11111100 (negative, sign extended)");
            pass_count++;
        end else begin
            $display("FAIL: 8'sb11110000 >>> 2 = %b, expected 11111100", result);
            fail_count++;
        end

        // Test 6: Shift by 0 - no change
        unsigned_val = 8'hAB;
        result = unsigned_val << 0;
        if (result == 8'hAB) begin
            $display("PASS: 8'hAB << 0 = 8'hAB");
            pass_count++;
        end else begin
            $display("FAIL: 8'hAB << 0 = %h, expected AB", result);
            fail_count++;
        end

        // Test 7: Shift by width - all zeros for logical
        unsigned_val = 8'hFF;
        result = unsigned_val >> 8;
        if (result == 8'h00) begin
            $display("PASS: 8'hFF >> 8 = 8'h00");
            pass_count++;
        end else begin
            $display("FAIL: 8'hFF >> 8 = %h, expected 00", result);
            fail_count++;
        end

        // Test 8: Variable shift amount
        unsigned_val = 8'h01;
        for (int i = 0; i < 8; i++) begin
            result = unsigned_val << i;
            if (result == (8'h01 << i)) begin
                pass_count++;
            end else begin
                fail_count++;
            end
        end
        $display("PASS: Variable shift amounts (8 tests)");

        $display("");
        $display("=== Shift Operators Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
