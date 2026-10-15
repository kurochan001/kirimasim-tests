/*
:name: test_concat_lhs
:description: Concatenations on the left-hand side of an assignment
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 10.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_lhs.expected
*/
// Concatenations on the left-hand side of an assignment

module test_concat_lhs;
    int pass_count = 0;
    int total_tests = 15;

    logic [7:0] byte_a, byte_b, byte_c, byte_d;
    logic [15:0] word_a, word_b;
    logic [31:0] dword;
    logic [3:0] nibble_a, nibble_b, nibble_c, nibble_d;
    logic single_a, single_b, single_c, single_d;
    logic [63:0] qword;

    initial begin
        // Test 1: Simple 2-element concat LHS
        {byte_a, byte_b} = 16'hABCD;
        if (byte_a == 8'hAB && byte_b == 8'hCD) begin
            pass_count++;
            $display("PASS: Simple 2-element concat LHS");
        end else $display("FAIL: Simple 2-element concat LHS, a=%h b=%h", byte_a, byte_b);

        // Test 2: 4-element concat LHS
        {byte_a, byte_b, byte_c, byte_d} = 32'h12345678;
        if (byte_a == 8'h12 && byte_b == 8'h34 && byte_c == 8'h56 && byte_d == 8'h78) begin
            pass_count++;
            $display("PASS: 4-element concat LHS");
        end else $display("FAIL: 4-element concat LHS");

        // Test 3: Mixed width concat
        {word_a, byte_a} = 24'hABCDEF;
        if (word_a == 16'hABCD && byte_a == 8'hEF) begin
            pass_count++;
            $display("PASS: Mixed width concat LHS");
        end else $display("FAIL: Mixed width concat LHS");

        // Test 4: Nibble concat
        {nibble_a, nibble_b, nibble_c, nibble_d} = 16'h1234;
        if (nibble_a == 4'h1 && nibble_b == 4'h2 && nibble_c == 4'h3 && nibble_d == 4'h4) begin
            pass_count++;
            $display("PASS: Nibble concat LHS");
        end else $display("FAIL: Nibble concat LHS");

        // Test 5: Single bit concat
        {single_a, single_b, single_c, single_d} = 4'b1010;
        if (single_a == 1 && single_b == 0 && single_c == 1 && single_d == 0) begin
            pass_count++;
            $display("PASS: Single bit concat LHS");
        end else $display("FAIL: Single bit concat LHS");

        // Test 6: Concat with word boundary
        {word_a, word_b} = 32'hDEADBEEF;
        if (word_a == 16'hDEAD && word_b == 16'hBEEF) begin
            pass_count++;
            $display("PASS: Word boundary concat");
        end else $display("FAIL: Word boundary concat");

        // Test 7: Concat LHS from expression
        dword = 32'hCAFEBABE;
        {byte_a, byte_b, byte_c, byte_d} = dword;
        if (byte_a == 8'hCA && byte_d == 8'hBE) begin
            pass_count++;
            $display("PASS: Concat LHS from expression");
        end else $display("FAIL: Concat LHS from expression");

        // Test 8: Nested concat (if supported)
        {{nibble_a, nibble_b}, {nibble_c, nibble_d}} = 16'hABCD;
        if (nibble_a == 4'hA && nibble_b == 4'hB && nibble_c == 4'hC && nibble_d == 4'hD) begin
            pass_count++;
            $display("PASS: Nested concat LHS");
        end else $display("FAIL: Nested concat LHS");

        // Test 9: Wide concat (64-bit)
        {dword, word_a, word_b} = 64'h123456789ABCDEF0;
        if (dword == 32'h12345678 && word_a == 16'h9ABC && word_b == 16'hDEF0) begin
            pass_count++;
            $display("PASS: Wide 64-bit concat");
        end else $display("FAIL: Wide 64-bit concat");

        // Test 10: Concat with part-select source
        qword = 64'hFEDCBA9876543210;
        {byte_a, byte_b} = qword[63:48];
        if (byte_a == 8'hFE && byte_b == 8'hDC) begin
            pass_count++;
            $display("PASS: Concat from part-select");
        end else $display("FAIL: Concat from part-select");

        // Test 11: Concat with different orderings
        {byte_d, byte_c, byte_b, byte_a} = 32'h11223344;
        if (byte_d == 8'h11 && byte_a == 8'h44) begin
            pass_count++;
            $display("PASS: Concat reverse order");
        end else $display("FAIL: Concat reverse order");

        // Test 12: Concat with zero padding source
        {word_a, word_b} = 8'hFF;  // Zero-extended to 32 bits
        if (word_a == 16'h0000 && word_b == 16'h00FF) begin
            pass_count++;
            $display("PASS: Concat zero padding");
        end else $display("FAIL: Concat zero padding, a=%h b=%h", word_a, word_b);

        // Test 13: Concat partial assignment (slice as LHS element)
        byte_a = 8'hAA;
        byte_b = 8'hBB;
        {byte_a[7:4], byte_b[3:0]} = 8'hCD;
        if (byte_a == 8'hCA && byte_b == 8'hBD) begin
            pass_count++;
            $display("PASS: Concat with slice elements");
        end else $display("FAIL: Concat with slice elements, a=%h b=%h", byte_a, byte_b);

        // Test 14: Single element + multi element
        {single_a, byte_a} = 9'b1_10101010;
        if (single_a == 1 && byte_a == 8'hAA) begin
            pass_count++;
            $display("PASS: Single + multi element concat");
        end else $display("FAIL: Single + multi element concat");

        // Test 15: All same width elements
        {byte_a, byte_b, byte_c, byte_d} = {8'hAA, 8'hBB, 8'hCC, 8'hDD};
        if (byte_a == 8'hAA && byte_b == 8'hBB && byte_c == 8'hCC && byte_d == 8'hDD) begin
            pass_count++;
            $display("PASS: Concat from concat RHS");
        end else $display("FAIL: Concat from concat RHS");

        $display("PASS: concat_lhs (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
