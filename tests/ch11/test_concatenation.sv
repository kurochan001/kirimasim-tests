/*
:name: test_concatenation
:description: Concatenation Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1 10.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concatenation.expected
*/
// IEEE 1800-2023 Section 11.4.12 - Concatenation Tests
// Tests: {}, replication, nested concatenation

module test_concatenation;
    int pass_count = 0;
    int fail_count = 0;

    logic [3:0] nibble_a, nibble_b;
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;

    initial begin
        $display("=== IEEE 1800-2023 Concatenation Test ===");

        // Test 1: Basic concatenation
        $display("Test 1: Basic concatenation");
        nibble_a = 4'hA;
        nibble_b = 4'hB;
        byte_val = {nibble_a, nibble_b};
        $display("  {4'hA, 4'hB} = %h", byte_val);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Three-way concatenation
        $display("Test 2: Three-way concatenation");
        word_val = {nibble_a, byte_val, nibble_b};
        $display("  {4'hA, 8'hAB, 4'hB} = %h", word_val);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Replication
        $display("Test 3: Replication");
        byte_val = {4{2'b10}};
        $display("  {4{2'b10}} = %b", byte_val);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Replication with value
        $display("Test 4: Replication with value");
        word_val = {2{8'hAB}};
        $display("  {2{8'hAB}} = %h", word_val);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Nested concatenation
        $display("Test 5: Nested concatenation");
        dword_val = {{2{8'hAA}}, {2{8'hBB}}};
        $display("  {{2{8'hAA}}, {2{8'hBB}}} = %h", dword_val);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Concatenation with literals
        $display("Test 6: Concatenation with literals");
        byte_val = {4'b1111, 4'b0000};
        $display("  {4'b1111, 4'b0000} = %b", byte_val);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Single bit concatenation
        $display("Test 7: Single bit concatenation");
        nibble_a = {1'b1, 1'b0, 1'b1, 1'b0};
        $display("  {1,0,1,0} = %b", nibble_a);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Mixed replication and concat
        $display("Test 8: Mixed replication and concat");
        byte_val = {{4{1'b1}}, {4{1'b0}}};
        $display("  {{4{1}}, {4{0}}} = %b", byte_val);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Concat in assignment
        $display("Test 9: Concat in assignment");
        {nibble_a, nibble_b} = 8'hCD;
        $display("  After {a,b}=8'hCD: a=%h, b=%h", nibble_a, nibble_b);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Zero extension via concat
        $display("Test 10: Zero extension via concat");
        nibble_a = 4'hF;
        byte_val = {4'b0000, nibble_a};
        $display("  {4'b0, 4'hF} = %h", byte_val);
        $display("Test 10 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
