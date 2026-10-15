/*
:name: test_expr_primary
:description: Primary expressions test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_primary.expected
*/
// Primary expressions test
module test_expr_primary;
    int num;
    real r;
    string str;
    logic [7:0] byte_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Integer literal
        num = 42;
        if (num == 42) begin
            $display("PASS: Integer literal 42");
            pass_count++;
        end else begin
            $display("FAIL: Integer literal, expected 42, got %0d", num);
            fail_count++;
        end

        // Test 2: Real literal
        r = 3.14159;
        if (r > 3.14 && r < 3.15) begin
            $display("PASS: Real literal 3.14159");
            pass_count++;
        end else begin
            $display("FAIL: Real literal, got %f", r);
            fail_count++;
        end

        // Test 3: String literal
        str = "Hello";
        if (str == "Hello") begin
            $display("PASS: String literal \"Hello\"");
            pass_count++;
        end else begin
            $display("FAIL: String literal failed");
            fail_count++;
        end

        // Test 4: Binary literal with size
        byte_val = 8'b10101010;
        if (byte_val == 8'hAA) begin
            $display("PASS: Binary literal 8'b10101010 = 0xAA");
            pass_count++;
        end else begin
            $display("FAIL: Binary literal, expected 0xAA, got 0x%02X", byte_val);
            fail_count++;
        end

        // Test 5: Parenthesized expression
        num = ((5 + 3) * 2);
        if (num == 16) begin
            $display("PASS: Parenthesized ((5+3)*2) = 16");
            pass_count++;
        end else begin
            $display("FAIL: Parenthesized expr, expected 16, got %0d", num);
            fail_count++;
        end

        // Summary
        $display("Primary expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All primary expression tests passed");
        else $display("FAIL: Some primary expression tests failed");
        $finish;
    end
endmodule
