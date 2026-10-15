/*
:name: test_literal_corner
:description: Tests various literal formats and representations
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 5.7.2 5.9 6.16
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_literal_corner.expected
*/
// Tests various literal formats and representations
`timescale 1ns/1ps

module test_literal_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Binary literals
    task test_binary_literals();
        logic [7:0] val;

        val = 8'b10101010;
        if (val == 8'hAA) begin
            $display("PASS: Binary literal 8'b10101010 = 0xAA");
            pass_count++;
        end else begin
            $display("FAIL: Binary literal failed");
            fail_count++;
        end

        val = 8'b1010_1010;  // With underscore
        if (val == 8'hAA) begin
            $display("PASS: Binary literal with underscore");
            pass_count++;
        end else begin
            $display("FAIL: Binary underscore failed");
            fail_count++;
        end
    endtask

    // Test 2: Hex literals
    task test_hex_literals();
        logic [31:0] val;

        val = 32'hDEAD_BEEF;
        if (val == 32'hDEADBEEF) begin
            $display("PASS: Hex literal with underscore");
            pass_count++;
        end else begin
            $display("FAIL: Hex literal failed");
            fail_count++;
        end

        val = 32'hcafe_babe;  // Lowercase
        if (val == 32'hCAFEBABE) begin
            $display("PASS: Lowercase hex literal");
            pass_count++;
        end else begin
            $display("FAIL: Lowercase hex failed");
            fail_count++;
        end
    endtask

    // Test 3: Octal literals
    task test_octal_literals();
        logic [8:0] val;

        val = 9'o777;
        if (val == 9'b111111111) begin
            $display("PASS: Octal literal 9'o777");
            pass_count++;
        end else begin
            $display("FAIL: Octal literal failed");
            fail_count++;
        end
    endtask

    // Test 4: Decimal literals
    task test_decimal_literals();
        logic [7:0] val;

        val = 8'd255;
        if (val == 8'hFF) begin
            $display("PASS: Decimal literal 8'd255");
            pass_count++;
        end else begin
            $display("FAIL: Decimal literal failed");
            fail_count++;
        end

        val = 8'd100;
        if (val == 100) begin
            $display("PASS: Decimal literal 8'd100");
            pass_count++;
        end else begin
            $display("FAIL: Decimal 100 failed");
            fail_count++;
        end
    endtask

    // Test 5: Unsized literals
    task test_unsized_literals();
        int val;

        val = 'hFF;  // Unsized hex
        if (val == 255) begin
            $display("PASS: Unsized hex literal 'hFF");
            pass_count++;
        end else begin
            $display("FAIL: Unsized hex failed");
            fail_count++;
        end

        val = 'd100;  // Unsized decimal
        if (val == 100) begin
            $display("PASS: Unsized decimal literal");
            pass_count++;
        end else begin
            $display("FAIL: Unsized decimal failed");
            fail_count++;
        end
    endtask

    // Test 6: Signed literals
    task test_signed_literals();
        logic signed [7:0] val;

        val = 8'sd255;  // Signed decimal (wraps to -1)
        if (val == -1) begin
            $display("PASS: Signed literal wraps correctly");
            pass_count++;
        end else begin
            $display("FAIL: Signed literal (val=%0d)", val);
            fail_count++;
        end

        val = -8'sd1;
        if (val == -1) begin
            $display("PASS: Negative signed literal");
            pass_count++;
        end else begin
            $display("FAIL: Negative literal failed");
            fail_count++;
        end
    endtask

    // Test 7: X and Z in literals
    task test_x_z_literals();
        logic [7:0] val;

        val = 8'bxxxx_xxxx;
        if ($isunknown(val)) begin
            $display("PASS: X literal creates unknown");
            pass_count++;
        end else begin
            $display("FAIL: X literal failed");
            fail_count++;
        end

        val = 8'bzzzz_zzzz;
        if (val === 8'hzz) begin
            $display("PASS: Z literal creates high-Z");
            pass_count++;
        end else begin
            $display("FAIL: Z literal (val=%h)", val);
            fail_count++;
        end
    endtask

    // Test 8: Mixed case in base
    task test_mixed_case_base();
        logic [7:0] val;

        val = 8'Haa;  // Capital H, lowercase digits
        if (val == 8'hAA) begin
            $display("PASS: Mixed case base specifier");
            pass_count++;
        end else begin
            $display("FAIL: Mixed case failed");
            fail_count++;
        end

        val = 8'B1010_1010;  // Capital B
        if (val == 8'hAA) begin
            $display("PASS: Capital B binary");
            pass_count++;
        end else begin
            $display("FAIL: Capital B failed");
            fail_count++;
        end
    endtask

    // Test 9: Real literals
    task test_real_literals();
        real r;

        r = 3.14159;
        if (r > 3.14 && r < 3.15) begin
            $display("PASS: Real literal 3.14159");
            pass_count++;
        end else begin
            $display("FAIL: Real literal failed");
            fail_count++;
        end

        r = 1.0e-3;
        if (r > 0.0009 && r < 0.0011) begin
            $display("PASS: Scientific notation 1.0e-3");
            pass_count++;
        end else begin
            $display("FAIL: Scientific notation failed");
            fail_count++;
        end
    endtask

    // Test 10: String literals
    task test_string_literals();
        string s;

        s = "Hello World";
        if (s.len() == 11) begin
            $display("PASS: String literal");
            pass_count++;
        end else begin
            $display("FAIL: String literal failed");
            fail_count++;
        end

        s = "Tab\tHere";
        if (s.len() > 0) begin
            $display("PASS: String with escape");
            pass_count++;
        end else begin
            $display("FAIL: Escape string failed");
            fail_count++;
        end
    endtask

    // Test 11: Width vs value mismatch
    task test_width_mismatch();
        logic [3:0] val;

        val = 4'hFF;  // Value larger than width
        if (val == 4'hF) begin
            $display("PASS: Literal truncated to fit width");
            pass_count++;
        end else begin
            $display("FAIL: Width mismatch (val=%h)", val);
            fail_count++;
        end
    endtask

    // Test 12: Zero literals
    task test_zero_literals();
        logic [7:0] val;

        val = 8'b0;
        if (val == 0) begin
            $display("PASS: 8'b0 = 0");
            pass_count++;
        end else begin
            $display("FAIL: Zero literal failed");
            fail_count++;
        end

        val = 8'd0;
        if (val == 0) begin
            $display("PASS: 8'd0 = 0");
            pass_count++;
        end else begin
            $display("FAIL: Decimal zero failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Literal Value Corner Cases Test ===");

        test_binary_literals();
        test_hex_literals();
        test_octal_literals();
        test_decimal_literals();
        test_unsized_literals();
        test_signed_literals();
        test_x_z_literals();
        test_mixed_case_base();
        test_real_literals();
        test_string_literals();
        test_width_mismatch();
        test_zero_literals();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
