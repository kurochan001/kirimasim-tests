/*
:name: test_expression_width
:description: Expression Width Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expression_width.expected
*/
// IEEE 1800-2023 Section 11.6 - Expression Width Tests
// Tests: Width extension, context-determined expressions

module test_expression_width;
    int pass_count = 0;
    int fail_count = 0;

    logic [3:0] a4;
    logic [7:0] a8;
    logic [15:0] a16;
    logic [31:0] a32;

    logic signed [7:0] s8;
    logic signed [15:0] s16;

    initial begin
        $display("=== IEEE 1800-2023 Expression Width Tests ===");

        // Test 1: Width extension in assignment
        $display("Test 1: Width extension in assignment");
        a4 = 4'hF;
        a8 = a4;  // Zero-extend to 8 bits
        if (a8 == 8'h0F) begin
            $display("Test 1 PASS: 4->8 bit extension=%h", a8);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", a8);
            fail_count++;
        end

        // Test 2: Arithmetic width extension
        $display("Test 2: Arithmetic width extension");
        a8 = 8'hFF;
        a16 = a8 + 1;  // Result is context-sized
        if (a16 == 16'h0100) begin
            $display("Test 2 PASS: FF+1=%h (extended)", a16);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", a16);
            fail_count++;
        end

        // Test 3: Multiplication width
        $display("Test 3: Multiplication width");
        a8 = 8'h10;
        a16 = a8 * a8;
        if (a16 == 16'h0100) begin
            $display("Test 3 PASS: 10*10=%h", a16);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", a16);
            fail_count++;
        end

        // Test 4: Signed extension
        $display("Test 4: Signed extension");
        s8 = -8'sd5;
        s16 = s8;  // Sign-extend to 16 bits
        if (s16 == -16'sd5) begin
            $display("Test 4 PASS: signed -5 extended=%d", s16);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %d", s16);
            fail_count++;
        end

        // Test 5: Concatenation width
        $display("Test 5: Concatenation width");
        a8 = 8'hAB;
        a16 = {a8, a8};
        if (a16 == 16'hABAB) begin
            $display("Test 5 PASS: concat {AB,AB}=%h", a16);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %h", a16);
            fail_count++;
        end

        // Test 6: Shift width
        $display("Test 6: Shift width");
        a8 = 8'h01;
        a8 = a8 << 4;
        if (a8 == 8'h10) begin
            $display("Test 6 PASS: 01<<4=%h", a8);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", a8);
            fail_count++;
        end

        // Test 7: Wide literal
        $display("Test 7: Wide literal");
        a32 = 32'hDEADBEEF;
        if (a32 == 32'hDEADBEEF) begin
            $display("Test 7 PASS: 32-bit literal=%h", a32);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", a32);
            fail_count++;
        end

        // Test 8: Truncation
        $display("Test 8: Truncation");
        a16 = 16'h1234;
        a8 = a16;  // Truncate to 8 bits
        if (a8 == 8'h34) begin
            $display("Test 8 PASS: truncate 1234->%h", a8);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", a8);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
