/*
:name: test_slice_assign
:description: Test: Part-select assignment [a:b] = val
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_slice_assign.expected
*/
// Test: Part-select assignment [a:b] = val

module test_slice_assign;
    int pass_count = 0;
    int total_tests = 15;

    logic [31:0] wide_reg;
    logic [15:0] word_reg;
    logic [7:0] byte_reg;
    logic [63:0] extra_wide;
    int idx;

    initial begin
        // Test 1: Simple constant part-select assignment
        wide_reg = 32'h00000000;
        wide_reg[7:0] = 8'hAB;
        if (wide_reg == 32'h000000AB) begin
            pass_count++;
            $display("PASS: Simple constant part-select");
        end else $display("FAIL: Simple constant part-select, got %h", wide_reg);

        // Test 2: Upper bits part-select
        wide_reg = 32'h00000000;
        wide_reg[31:24] = 8'hCD;
        if (wide_reg == 32'hCD000000) begin
            pass_count++;
            $display("PASS: Upper bits part-select");
        end else $display("FAIL: Upper bits part-select, got %h", wide_reg);

        // Test 3: Middle part-select
        wide_reg = 32'h00000000;
        wide_reg[23:16] = 8'hEF;
        if (wide_reg == 32'h00EF0000) begin
            pass_count++;
            $display("PASS: Middle part-select");
        end else $display("FAIL: Middle part-select, got %h", wide_reg);

        // Test 4: Multiple part-selects (preserve others)
        wide_reg = 32'hAAAAAAAA;
        wide_reg[15:8] = 8'h55;
        if (wide_reg == 32'hAAAA55AA) begin
            pass_count++;
            $display("PASS: Part-select preserves other bits");
        end else $display("FAIL: Part-select preserves other bits, got %h", wide_reg);

        // Test 5: Single bit assignment
        wide_reg = 32'h00000000;
        wide_reg[0] = 1;
        wide_reg[31] = 1;
        if (wide_reg == 32'h80000001) begin
            pass_count++;
            $display("PASS: Single bit assignment");
        end else $display("FAIL: Single bit assignment, got %h", wide_reg);

        // Test 6: Indexed part-select +: (ascending)
        wide_reg = 32'h00000000;
        idx = 8;
        wide_reg[idx +: 8] = 8'hFF;  // bits [15:8]
        if (wide_reg == 32'h0000FF00) begin
            pass_count++;
            $display("PASS: Indexed +: part-select");
        end else $display("FAIL: Indexed +: part-select, got %h", wide_reg);

        // Test 7: Indexed part-select -: (descending)
        wide_reg = 32'h00000000;
        idx = 23;
        wide_reg[idx -: 8] = 8'hAA;  // bits [23:16]
        if (wide_reg == 32'h00AA0000) begin
            pass_count++;
            $display("PASS: Indexed -: part-select");
        end else $display("FAIL: Indexed -: part-select, got %h", wide_reg);

        // Test 8: Variable index +: at boundary
        wide_reg = 32'h00000000;
        idx = 0;
        wide_reg[idx +: 16] = 16'hBEEF;  // bits [15:0]
        if (wide_reg == 32'h0000BEEF) begin
            pass_count++;
            $display("PASS: Variable +: at boundary");
        end else $display("FAIL: Variable +: at boundary, got %h", wide_reg);

        // Test 9: 64-bit slice operations
        extra_wide = 64'h0000000000000000;
        extra_wide[63:32] = 32'hDEADBEEF;
        extra_wide[31:0] = 32'hCAFEBABE;
        if (extra_wide == 64'hDEADBEEFCAFEBABE) begin
            pass_count++;
            $display("PASS: 64-bit slice");
        end else $display("FAIL: 64-bit slice");

        // Test 10: Overlapping writes (last wins)
        wide_reg = 32'h00000000;
        wide_reg[15:0] = 16'hAAAA;
        wide_reg[23:8] = 16'hBBBB;  // Overlaps bits [15:8]
        if (wide_reg[23:8] == 16'hBBBB) begin
            pass_count++;
            $display("PASS: Overlapping writes");
        end else $display("FAIL: Overlapping writes");

        // Test 11: Zero-width behavior (single bit)
        byte_reg = 8'h00;
        byte_reg[3:3] = 1;
        if (byte_reg == 8'h08) begin
            pass_count++;
            $display("PASS: Zero-width (single bit)");
        end else $display("FAIL: Zero-width (single bit), got %h", byte_reg);

        // Test 12: Word slice from expression
        wide_reg = 32'h12345678;
        word_reg = wide_reg[31:16];
        if (word_reg == 16'h1234) begin
            pass_count++;
            $display("PASS: Word slice from expression");
        end else $display("FAIL: Word slice from expression");

        // Test 13: Chain of slices
        wide_reg = 32'h00000000;
        wide_reg[7:0] = 8'h11;
        wide_reg[15:8] = 8'h22;
        wide_reg[23:16] = 8'h33;
        wide_reg[31:24] = 8'h44;
        if (wide_reg == 32'h44332211) begin
            pass_count++;
            $display("PASS: Chain of slices");
        end else $display("FAIL: Chain of slices, got %h", wide_reg);

        // Test 14: Slice with X/Z values
        wide_reg = 32'hFFFFFFFF;
        wide_reg[11:4] = 8'bxxxx_zzzz;
        if (wide_reg[3:0] == 4'hF && wide_reg[31:12] == 20'hFFFFF) begin
            pass_count++;
            $display("PASS: Slice with X/Z values");
        end else $display("FAIL: Slice with X/Z values");

        // Test 15: Slice assignment from slice
        wide_reg = 32'hABCD1234;
        extra_wide = 64'h0;
        extra_wide[31:16] = wide_reg[15:0];
        if (extra_wide[31:16] == 16'h1234) begin
            pass_count++;
            $display("PASS: Slice from slice");
        end else $display("FAIL: Slice from slice");

        $display("PASS: slice_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
