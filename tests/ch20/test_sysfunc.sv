/*
:name: test_sysfunc
:description: Bit query and array query system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 20.7 20.8.1 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sysfunc.expected
*/
// Bit query and array query system functions
module test_sysfunc;
    int pass_count = 0;
    int test_count = 0;
    int val;
    real rval;
    string str;
    logic [31:0] bits;
    
    initial begin
        // Test 1: $clog2
        test_count++;
        if ($clog2(8) == 3) pass_count++;
        
        // Test 2: $clog2 edge
        test_count++;
        if ($clog2(1) == 0) pass_count++;
        
        // Test 3: $countones
        test_count++;
        bits = 32'hF0F0F0F0;
        if ($countones(bits) == 16) pass_count++;
        
        // Test 4: $onehot
        test_count++;
        bits = 32'h00000010;
        if ($onehot(bits)) pass_count++;
        
        // Test 5: $onehot0
        test_count++;
        bits = 32'h00000000;
        if ($onehot0(bits)) pass_count++;
        
        // Test 6: $isunknown
        test_count++;
        bits = 32'h12345678;
        if (!$isunknown(bits)) pass_count++;
        
        // Test 7: $bits
        test_count++;
        if ($bits(bits) == 32) pass_count++;
        
        // Test 8: $size
        test_count++;
        begin
            int arr[10];
            if ($size(arr) == 10) pass_count++;
        end
        
        // Test 9: $left/$right
        test_count++;
        begin
            logic [7:0] byte_val;
            if ($left(byte_val) == 7 && $right(byte_val) == 0) pass_count++;
        end
        
        // Test 10: $high/$low
        test_count++;
        begin
            int arr[5:10];
            if ($low(arr) == 5 && $high(arr) == 10) pass_count++;
        end
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
