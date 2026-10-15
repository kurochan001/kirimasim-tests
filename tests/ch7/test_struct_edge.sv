/*
:name: test_struct_edge
:description: Test: Struct operation edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 11.4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_edge.expected
*/
// Test: Struct operation edge cases
module test_struct_edge;
    int pass_count = 0;
    int test_count = 0;
    
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [15:0] c;
    } packed_s;
    
    typedef struct {
        int x;
        string name;
        logic [31:0] data;
    } unpacked_s;
    
    packed_s ps1, ps2;
    unpacked_s us1, us2;
    
    initial begin
        // Test 1: Packed struct assignment
        test_count++;
        ps1 = '{8'hAA, 8'hBB, 16'hCCDD};
        if (ps1.a == 8'hAA) pass_count++;
        
        // Test 2: Packed struct as bits
        test_count++;
        if (ps1 == 32'hAABBCCDD) pass_count++;
        
        // Test 3: Member access
        test_count++;
        if (ps1.c == 16'hCCDD) pass_count++;
        
        // Test 4: Packed struct copy
        test_count++;
        ps2 = ps1;
        if (ps2.b == 8'hBB) pass_count++;
        
        // Test 5: Unpacked struct
        test_count++;
        us1.x = 100;
        us1.name = "test";
        us1.data = 32'h12345678;
        if (us1.x == 100) pass_count++;
        
        // Test 6: Unpacked string member
        test_count++;
        if (us1.name == "test") pass_count++;
        
        // Test 7: Unpacked copy
        test_count++;
        us2 = us1;
        if (us2.data == 32'h12345678) pass_count++;
        
        // Test 8: Modify member
        test_count++;
        ps1.a = 8'h11;
        if (ps1.a == 8'h11 && ps1.b == 8'hBB) pass_count++;
        
        // Test 9: Struct comparison
        test_count++;
        ps2.a = 8'h11;
        if (ps1 == ps2) pass_count++;
        
        // Test 10: Default values
        test_count++;
        ps1 = '{default: 8'h0};
        if (ps1 == 32'h0) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
