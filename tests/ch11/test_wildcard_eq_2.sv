/*
:name: test_wildcard_eq_2
:description: Wildcard equality ==? and !=? with x, z and ? in the right operand
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wildcard_eq_2.expected
*/
// Wildcard equality ==? and !=? with x, z and ? in the right operand

module test_wildcard_eq;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    logic [7:0] data;
    logic [7:0] pattern;
    logic [3:0] nibble;
    logic [15:0] wide;
    logic result;

    initial begin
        // Test 1: Exact match with ==?
        data = 8'b10101010;
        pattern = 8'b10101010;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 1 PASSED: exact match ==?");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Mismatch with ==?
        data = 8'b10101010;
        pattern = 8'b01010101;
        result = (data ==? pattern);
        if (result == 1'b0) begin
            $display("Test 2 PASSED: mismatch ==?");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Wildcard X in pattern (matches anything)
        data = 8'b10101010;
        pattern = 8'b1010xxxx;  // Lower 4 bits are don't care
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 3 PASSED: X wildcard matches");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Wildcard Z in pattern
        data = 8'b10101010;
        pattern = 8'b1010????;  // Lower 4 bits are don't care (? = z)
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 4 PASSED: Z wildcard matches");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Pattern with mixed wildcards
        data = 8'b11110000;
        pattern = 8'bxxxx0000;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 5 PASSED: upper X, lower exact");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Pattern mismatch in non-wildcard
        data = 8'b11110001;
        pattern = 8'bxxxx0000;
        result = (data ==? pattern);
        if (result == 1'b0) begin
            $display("Test 6 PASSED: non-wildcard mismatch");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: All wildcards
        data = 8'b10101010;
        pattern = 8'bxxxxxxxx;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 7 PASSED: all wildcards match anything");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: !=? exact match (should be false)
        data = 8'b11001100;
        pattern = 8'b11001100;
        result = (data !=? pattern);
        if (result == 1'b0) begin
            $display("Test 8 PASSED: !=? on exact match = 0");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: !=? with mismatch
        data = 8'b11001100;
        pattern = 8'b00110011;
        result = (data !=? pattern);
        if (result == 1'b1) begin
            $display("Test 9 PASSED: !=? on mismatch = 1");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: !=? with wildcard match
        data = 8'b11001100;
        pattern = 8'b1100xxxx;
        result = (data !=? pattern);
        if (result == 1'b0) begin
            $display("Test 10 PASSED: !=? with wildcard match = 0");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: !=? with wildcard but mismatch
        data = 8'b00001100;
        pattern = 8'b1100xxxx;
        result = (data !=? pattern);
        if (result == 1'b1) begin
            $display("Test 11 PASSED: !=? wildcard mismatch = 1");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Nibble wildcard equality
        nibble = 4'b1010;
        result = (nibble ==? 4'b10xx);
        if (result == 1'b1) begin
            $display("Test 12 PASSED: nibble wildcard ==?");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Single bit wildcard
        nibble = 4'b1011;
        result = (nibble ==? 4'b101x);
        if (result == 1'b1) begin
            $display("Test 13 PASSED: single bit wildcard");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Wide value wildcard
        wide = 16'hABCD;
        result = (wide ==? 16'hABxx);
        if (result == 1'b1) begin
            $display("Test 14 PASSED: 16-bit wildcard match");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Wide value wildcard mismatch
        wide = 16'hABCD;
        result = (wide ==? 16'hCDxx);
        if (result == 1'b0) begin
            $display("Test 15 PASSED: 16-bit wildcard mismatch");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Wildcard in case statement context
        data = 8'b10110100;
        if (data ==? 8'b1011xxxx) begin
            $display("Test 16 PASSED: wildcard in if condition");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Multiple wildcards scattered
        data = 8'b10101010;
        pattern = 8'bx0x0x0x0;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 17 PASSED: scattered wildcards");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Alternating pattern check
        data = 8'b01010101;
        pattern = 8'bx1x1x1x1;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 18 PASSED: alternating pattern");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Wildcard at MSB
        data = 8'b11111111;
        pattern = 8'bxxxx1111;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 19 PASSED: wildcard at MSB");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Wildcard at LSB
        data = 8'b11110000;
        pattern = 8'b1111xxxx;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 20 PASSED: wildcard at LSB");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Zero data with wildcard
        data = 8'b00000000;
        pattern = 8'bxxxx0000;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 21 PASSED: zero data with wildcard");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: All ones with wildcard
        data = 8'b11111111;
        pattern = 8'b1111xxxx;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 22 PASSED: all ones with wildcard");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Mixed z and x in pattern
        data = 8'b10101010;
        pattern = 8'b1x1x1z1z;
        result = (data ==? pattern);
        if (result == 1'b1) begin
            $display("Test 23 PASSED: mixed z and x wildcards");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Conditional with wildcard
        data = 8'hF0;
        result = (data ==? 8'hFx) ? 1'b1 : 1'b0;
        if (result == 1'b1) begin
            $display("Test 24 PASSED: wildcard in conditional");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Expression result comparison
        begin
            static logic [7:0] a = 8'hA5;
            static logic [7:0] b = 8'hAx;
            if ((a ==? b) == 1'b1) begin
                $display("Test 25 PASSED: expression wildcard comparison");
                pass_count++;
            end else $display("Test 25 FAILED");
        end

        $display("PASS: wildcard_eq (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
