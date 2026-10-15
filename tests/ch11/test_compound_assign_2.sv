/*
:name: test_compound_assign_2
:description: Compound assignment operators, including shifts and wrap-around
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compound_assign_2.expected
*/
// Compound assignment operators, including shifts and wrap-around

module test_compound_assign;
    int pass_count = 0;
    int total_tests = 15;

    int a, b;
    logic [7:0] byte_val;
    logic [31:0] wide_val;
    logic [3:0] small_val;

    initial begin
        // Test 1: Addition assignment
        a = 10;
        a += 5;
        if (a == 15) begin
            pass_count++;
            $display("PASS: Addition assignment +=");
        end else $display("FAIL: Addition assignment +=, got %0d", a);

        // Test 2: Subtraction assignment
        a = 20;
        a -= 8;
        if (a == 12) begin
            pass_count++;
            $display("PASS: Subtraction assignment -=");
        end else $display("FAIL: Subtraction assignment -=, got %0d", a);

        // Test 3: Multiplication assignment
        a = 6;
        a *= 7;
        if (a == 42) begin
            pass_count++;
            $display("PASS: Multiplication assignment *=");
        end else $display("FAIL: Multiplication assignment *=, got %0d", a);

        // Test 4: Division assignment
        a = 100;
        a /= 4;
        if (a == 25) begin
            pass_count++;
            $display("PASS: Division assignment /=");
        end else $display("FAIL: Division assignment /=, got %0d", a);

        // Test 5: Modulo assignment
        a = 17;
        a %= 5;
        if (a == 2) begin
            pass_count++;
            $display("PASS: Modulo assignment %%=");
        end else $display("FAIL: Modulo assignment %%=, got %0d", a);

        // Test 6: AND assignment
        byte_val = 8'hFF;
        byte_val &= 8'h0F;
        if (byte_val == 8'h0F) begin
            pass_count++;
            $display("PASS: AND assignment &=");
        end else $display("FAIL: AND assignment &=, got %h", byte_val);

        // Test 7: OR assignment
        byte_val = 8'h0F;
        byte_val |= 8'hF0;
        if (byte_val == 8'hFF) begin
            pass_count++;
            $display("PASS: OR assignment |=");
        end else $display("FAIL: OR assignment |=, got %h", byte_val);

        // Test 8: XOR assignment
        byte_val = 8'hAA;
        byte_val ^= 8'hFF;
        if (byte_val == 8'h55) begin
            pass_count++;
            $display("PASS: XOR assignment ^=");
        end else $display("FAIL: XOR assignment ^=, got %h", byte_val);

        // Test 9: Left shift assignment
        byte_val = 8'h01;
        byte_val <<= 4;
        if (byte_val == 8'h10) begin
            pass_count++;
            $display("PASS: Left shift assignment <<=");
        end else $display("FAIL: Left shift assignment <<=, got %h", byte_val);

        // Test 10: Right shift assignment
        byte_val = 8'h80;
        byte_val >>= 3;
        if (byte_val == 8'h10) begin
            pass_count++;
            $display("PASS: Right shift assignment >>=");
        end else $display("FAIL: Right shift assignment >>=, got %h", byte_val);

        // Test 11: Arithmetic right shift assignment
        a = -16;
        a >>>= 2;
        if (a == -4) begin
            pass_count++;
            $display("PASS: Arithmetic right shift assignment >>>=");
        end else $display("FAIL: Arithmetic right shift assignment >>>=, got %0d", a);

        // Test 12: Compound with expression
        a = 10;
        b = 3;
        a += b * 2;  // a = 10 + 6 = 16
        if (a == 16) begin
            pass_count++;
            $display("PASS: Compound with expression");
        end else $display("FAIL: Compound with expression, got %0d", a);

        // Test 13: Compound with overflow handling
        small_val = 4'hF;
        small_val += 4'h2;  // Wraps: 15 + 2 = 17 -> 1
        if (small_val == 4'h1) begin
            pass_count++;
            $display("PASS: Compound with overflow wrap");
        end else $display("FAIL: Compound with overflow wrap, got %h", small_val);

        // Test 14: Chained compound
        a = 5;
        a += 1;
        a *= 2;
        a -= 3;  // (5+1)*2-3 = 9
        if (a == 9) begin
            pass_count++;
            $display("PASS: Chained compound assignments");
        end else $display("FAIL: Chained compound assignments, got %0d", a);

        // Test 15: Wide value compound
        wide_val = 32'h80000000;
        wide_val >>= 16;
        if (wide_val == 32'h00008000) begin
            pass_count++;
            $display("PASS: Wide value compound shift");
        end else $display("FAIL: Wide value compound shift, got %h", wide_val);

        $display("PASS: compound_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
