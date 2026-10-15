/*
:name: test_width_mismatch
:description: Extension and truncation when operand and target widths differ
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.7 11.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_width_mismatch.expected
*/
// Extension and truncation when operand and target widths differ
module test_width_mismatch;
    int pass_count = 0;
    int total_tests = 12;

    // Test variables of different widths
    logic [3:0] narrow;
    logic [7:0] mid_size;
    logic [15:0] wide;
    logic [31:0] very_wide;
    logic [63:0] huge;
    logic single_bit;

    initial begin
        // Test 1: Assign wider to narrower (truncation)
        wide = 16'hABCD;
        mid_size = wide;  // Truncates to lower 8 bits
        if (mid_size == 8'hCD) begin
            $display("PASS: Wide to narrow truncation");
            pass_count++;
        end else begin
            $display("FAIL: Truncation failed: expected 0xCD, got 0x%h", mid_size);
        end

        // Test 2: Assign narrower to wider (zero extension for unsigned)
        mid_size = 8'hFF;
        wide = mid_size;  // Zero extends
        if (wide == 16'h00FF) begin
            $display("PASS: Narrow to wide zero extension");
            pass_count++;
        end else begin
            $display("FAIL: Zero extension failed: expected 0x00FF, got 0x%h", wide);
        end

        // Test 3: Add different widths
        narrow = 4'hF;
        mid_size = 8'h01;
        wide = narrow + mid_size;
        if (wide == 16'h0010) begin
            $display("PASS: Add different widths");
            pass_count++;
        end else begin
            $display("FAIL: Add widths: expected 0x0010, got 0x%h", wide);
        end

        // Test 4: Multiply different widths
        narrow = 4'hF;  // 15
        mid_size = 8'h10; // 16
        wide = narrow * mid_size;
        if (wide == 16'h00F0) begin
            $display("PASS: Multiply different widths");
            pass_count++;
        end else begin
            $display("FAIL: Multiply widths: expected 0x00F0, got 0x%h", wide);
        end

        // Test 5: Comparison of different widths
        narrow = 4'hF;
        wide = 16'h000F;
        if (narrow == wide) begin
            $display("PASS: Compare different widths (equal)");
            pass_count++;
        end else begin
            $display("FAIL: Compare different widths failed");
        end

        // Test 6: Bitwise AND different widths
        narrow = 4'hF;
        wide = 16'hFFFF;
        very_wide = narrow & wide;
        if (very_wide == 32'h0000000F) begin
            $display("PASS: AND different widths");
            pass_count++;
        end else begin
            $display("FAIL: AND widths: expected 0x0F, got 0x%h", very_wide);
        end

        // Test 7: Shift with different widths
        narrow = 4'h2;
        mid_size = 8'h80;
        wide = mid_size >> narrow;
        if (wide == 16'h0020) begin
            $display("PASS: Shift with different widths");
            pass_count++;
        end else begin
            $display("FAIL: Shift widths: expected 0x0020, got 0x%h", wide);
        end

        // Test 8: Concatenation of different widths
        narrow = 4'hA;
        mid_size = 8'hBC;
        wide = {narrow, mid_size};
        if (wide == 16'h0ABC) begin
            $display("PASS: Concatenate different widths");
            pass_count++;
        end else begin
            $display("FAIL: Concat widths: expected 0x0ABC, got 0x%h", wide);
        end

        // Test 9: Single bit to wide
        single_bit = 1'b1;
        huge = single_bit;
        if (huge == 64'h0000000000000001) begin
            $display("PASS: Single bit to 64-bit extension");
            pass_count++;
        end else begin
            $display("FAIL: Single bit extension: got 0x%h", huge);
        end

        // Test 10: Wide to single bit
        huge = 64'hFFFFFFFFFFFFFFFE;
        single_bit = huge;  // Takes LSB
        if (single_bit == 1'b0) begin
            $display("PASS: 64-bit to single bit (LSB)");
            pass_count++;
        end else begin
            $display("FAIL: Wide to single: expected 0, got %b", single_bit);
        end

        // Test 11: Ternary with different widths
        narrow = 4'h1;
        mid_size = 8'hAA;
        wide = 16'hBBBB;
        very_wide = narrow ? mid_size : wide;
        if (very_wide == 32'h000000AA) begin
            $display("PASS: Ternary with different widths");
            pass_count++;
        end else begin
            $display("FAIL: Ternary widths: got 0x%h", very_wide);
        end

        // Test 12: Reduction of different widths
        narrow = 4'hF;
        mid_size = 8'h00;
        single_bit = &narrow & &mid_size;
        if (single_bit == 1'b0) begin
            $display("PASS: Reduction with different widths");
            pass_count++;
        end else begin
            $display("FAIL: Reduction widths: got %b", single_bit);
        end

        $display("PASS: width_mismatch (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
