/*
:name: test_union_edge
:description: Test: Union operation edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_union_edge.expected
*/
// Test: Union operation edge cases
module test_union_edge;
    int pass_count = 0;
    int test_count = 0;
    
    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] upper;
            logic [15:0] lower;
        } halves;
        struct packed {
            logic [7:0] b3, b2, b1, b0;
        } bytes;
    } data_u;
    
    data_u u1, u2;
    
    initial begin
        // Test 1: Word access
        test_count++;
        u1.word = 32'h12345678;
        if (u1.word == 32'h12345678) pass_count++;
        
        // Test 2: Half word access
        test_count++;
        if (u1.halves.lower == 16'h5678) pass_count++;
        
        // Test 3: Upper half
        test_count++;
        if (u1.halves.upper == 16'h1234) pass_count++;
        
        // Test 4: Byte access
        test_count++;
        if (u1.bytes.b0 == 8'h78) pass_count++;
        
        // Test 5: Byte 3
        test_count++;
        if (u1.bytes.b3 == 8'h12) pass_count++;
        
        // Test 6: Write via half
        test_count++;
        u1.halves.lower = 16'hABCD;
        if (u1.word == 32'h1234ABCD) pass_count++;
        
        // Test 7: Write via byte
        test_count++;
        u1.bytes.b2 = 8'hEF;
        if (u1.word == 32'h12EFABCD) pass_count++;
        
        // Test 8: Union copy
        test_count++;
        u2 = u1;
        if (u2.word == u1.word) pass_count++;
        
        // Test 9: Clear union
        test_count++;
        u1.word = 32'h0;
        if (u1.halves.lower == 0 && u1.halves.upper == 0) pass_count++;
        
        // Test 10: All ones
        test_count++;
        u1.word = 32'hFFFFFFFF;
        if (u1.bytes.b0 == 8'hFF) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
