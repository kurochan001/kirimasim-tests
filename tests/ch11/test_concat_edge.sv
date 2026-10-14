/*
:name: test_concat_edge
:description: Test: Concatenation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_edge.expected
*/
// Test: Concatenation edge cases
module test_concat_edge;
    int pass_count = 0;
    int test_count = 0;
    
    logic [7:0] byte_a, byte_b, byte_c, byte_d;
    logic [31:0] word;
    logic [63:0] dword;
    logic [3:0] nibble;
    
    initial begin
        // Test 1: Simple concatenation
        test_count++;
        byte_a = 8'h12;
        byte_b = 8'h34;
        word = {24'h0, byte_a};
        if (word == 32'h00000012) pass_count++;
        
        // Test 2: Multi-part concat
        test_count++;
        byte_c = 8'h56;
        byte_d = 8'h78;
        word = {byte_a, byte_b, byte_c, byte_d};
        if (word == 32'h12345678) pass_count++;
        
        // Test 3: Wide concatenation
        test_count++;
        dword = {word, word};
        if (dword == 64'h12345678_12345678) pass_count++;
        
        // Test 4: Single bit concat
        test_count++;
        nibble = {1'b1, 1'b0, 1'b1, 1'b0};
        if (nibble == 4'hA) pass_count++;
        
        // Test 5: Mixed width
        test_count++;
        word = {nibble, 12'hABC, 16'h1234};
        if (word == 32'hAABC1234) pass_count++;
        
        // Test 6: Zero padding
        test_count++;
        word = {24'b0, byte_a};
        if (word == 32'h00000012) pass_count++;
        
        // Test 7: Sign bit concat
        test_count++;
        word = {1'b1, 31'h7FFFFFFF};
        if (word == 32'hFFFFFFFF) pass_count++;
        
        // Test 8: Empty slice (edge)
        test_count++;
        word = {32{1'b1}};
        if (word == 32'hFFFFFFFF) pass_count++;
        
        // Test 9: Nested concat
        test_count++;
        word = {{byte_a, byte_b}, {byte_c, byte_d}};
        if (word == 32'h12345678) pass_count++;
        
        // Test 10: Part select in concat
        test_count++;
        word = 32'hABCDEF12;
        dword = {word[31:16], word[15:0], word};
        if (dword == 64'hABCDEF12_ABCDEF12) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
