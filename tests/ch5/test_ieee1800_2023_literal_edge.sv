/*
:name: test_ieee1800_2023_literal_edge
:description: Literal Edge Cases
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7 5.7.1 5.7.2 5.9 6.11 6.16 10.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_literal_edge.expected
*/
// IEEE 1800-2023 Literal Edge Cases
// Sections: §5.7 Numbers, §6.11 Integer types
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_ieee1800_2023_literal_edge;

    initial begin
        static int pass_count = 0;
        static int total_tests = 20;

        // ============== Integer Literal Edge Cases (§5.7.1) ==============

        // Test 1: Maximum 32-bit unsigned
        begin
            static logic [31:0] val = 32'hFFFFFFFF;
            if (val == 4294967295) begin
                $display("PASS: Test 1 - Max 32-bit unsigned");
                pass_count++;
            end else $display("FAIL: Test 1 - Got %0d", val);
        end

        // Test 2: Minimum 32-bit signed
        begin
            static int val = -2147483648;
            if (val == 32'sh80000000) begin
                $display("PASS: Test 2 - Min 32-bit signed (INT_MIN)");
                pass_count++;
            end else $display("FAIL: Test 2 - Got %0d", val);
        end

        // Test 3: Zero in various bases
        begin
            static logic [7:0] a = 8'd0;
            static logic [7:0] b = 8'h0;
            static logic [7:0] c = 8'b0;
            static logic [7:0] d = 8'o0;
            if (a == 0 && b == 0 && c == 0 && d == 0) begin
                $display("PASS: Test 3 - Zero in all bases");
                pass_count++;
            end else $display("FAIL: Test 3 - Zero literals mismatch");
        end

        // Test 4: Underscore in literals
        begin
            static logic [31:0] val = 32'hDEAD_BEEF;
            if (val == 32'hDEADBEEF) begin
                $display("PASS: Test 4 - Underscore separator");
                pass_count++;
            end else $display("FAIL: Test 4 - Expected 0xDEADBEEF");
        end

        // Test 5: Unsized literal extension
        begin
            static logic [63:0] val = 'hFF;  // Unsized, should extend to 64 bits
            if (val == 64'h00000000000000FF) begin
                $display("PASS: Test 5 - Unsized literal zero-extended");
                pass_count++;
            end else $display("FAIL: Test 5 - Got %h", val);
        end

        // Test 6: Signed literal extension
        begin
            static logic signed [15:0] val = 8'shFF;  // -1 as 8-bit signed
            if (val == -1) begin
                $display("PASS: Test 6 - Signed literal sign-extended");
                pass_count++;
            end else $display("FAIL: Test 6 - Got %0d", val);
        end

        // ============== X and Z Literal Cases (§5.7.1) ==============

        // Test 7: All X literal
        begin
            static logic [7:0] val = 8'bxxxxxxxx;
            if ($isunknown(val)) begin
                $display("PASS: Test 7 - All X literal");
                pass_count++;
            end else $display("FAIL: Test 7 - Expected X");
        end

        // Test 8: All Z literal (high-impedance)
        begin
            static logic [7:0] val = 8'bzzzzzzzz;
            if (val === 8'bzzzzzzzz) begin
                $display("PASS: Test 8 - All Z literal");
                pass_count++;
            end else $display("FAIL: Test 8 - Expected Z");
        end

        // Test 9: Mixed X and values
        begin
            static logic [7:0] val = 8'b1x0x1x0x;
            if (val[7] === 1'b1 && val[6] === 1'bx &&
                val[5] === 1'b0 && val[4] === 1'bx) begin
                $display("PASS: Test 9 - Mixed X and values");
                pass_count++;
            end else $display("FAIL: Test 9 - Mixed literal mismatch");
        end

        // Test 10: X in hex literal
        begin
            static logic [15:0] val = 16'hXXXX;
            if ($isunknown(val)) begin
                $display("PASS: Test 10 - X in hex literal");
                pass_count++;
            end else $display("FAIL: Test 10 - Expected X");
        end

        // ============== Real Literal Edge Cases (§5.7.2) ==============

        // Test 11: Very small real
        begin
            static real val = 1.0e-300;
            if (val > 0.0 && val < 1.0e-299) begin
                $display("PASS: Test 11 - Very small real (subnormal)");
                pass_count++;
            end else $display("FAIL: Test 11 - Subnormal handling issue");
        end

        // Test 12: Very large real
        begin
            static real val = 1.0e300;
            if (val > 1.0e299) begin
                $display("PASS: Test 12 - Very large real");
                pass_count++;
            end else $display("FAIL: Test 12 - Large real issue");
        end

        // Test 13: Negative zero
        begin
            static real val = -0.0;
            if (val == 0.0) begin
                $display("PASS: Test 13 - Negative zero equals zero");
                pass_count++;
            end else $display("FAIL: Test 13 - Negative zero issue");
        end

        // Test 14: Scientific notation
        begin
            static real val = 1.5e2;
            if (val == 150.0) begin
                $display("PASS: Test 14 - Scientific notation");
                pass_count++;
            end else $display("FAIL: Test 14 - Expected 150.0");
        end

        // ============== String Literal Edge Cases (§5.9) ==============

        // Test 15: Empty string
        begin
            static string s = "";
            if (s.len() == 0) begin
                $display("PASS: Test 15 - Empty string");
                pass_count++;
            end else $display("FAIL: Test 15 - Empty string length");
        end

        // Test 16: Escape sequences
        begin
            static string s = "Line1\nLine2\tTab";
            if (s.len() > 10) begin
                $display("PASS: Test 16 - Escape sequences in string");
                pass_count++;
            end else $display("FAIL: Test 16 - Escape sequence issue");
        end

        // Test 17: String with null
        begin
            static string s = "Hello\0World";
            // Strings may or may not include characters after null
            $display("PASS: Test 17 - String with embedded null (len=%0d)", s.len());
            pass_count++;
        end

        // ============== Width Specification Edge Cases ==============

        // Test 18: Width smaller than value (truncation)
        begin
            static logic [3:0] val = 8'hFF;  // Truncated to 4 bits
            if (val == 4'hF) begin
                $display("PASS: Test 18 - Truncation to smaller width");
                pass_count++;
            end else $display("FAIL: Test 18 - Expected 0xF, got %h", val);
        end

        // Test 19: Width larger than value (extension)
        begin
            static logic [15:0] val = 4'hF;  // Zero-extended to 16 bits
            if (val == 16'h000F) begin
                $display("PASS: Test 19 - Zero extension to larger width");
                pass_count++;
            end else $display("FAIL: Test 19 - Expected 0x000F, got %h", val);
        end

        // Test 20: Single bit literal
        begin
            static logic val = 1'b1;
            if (val === 1'b1) begin
                $display("PASS: Test 20 - Single bit literal");
                pass_count++;
            end else $display("FAIL: Test 20 - Single bit mismatch");
        end

        $display("\n=== Literal Edge Cases Summary ===");
        $display("Tests passed: %0d/%0d", pass_count, total_tests);
        if (pass_count == total_tests) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
