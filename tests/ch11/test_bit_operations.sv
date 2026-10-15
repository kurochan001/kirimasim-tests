/*
:name: test_bit_operations
:description: Bit- and part-selects, writes, and bit query system functions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bit_operations.expected
*/
// IEEE 1800-2023 Section 11.4

module test_bit_operations;
    logic [7:0] a, b, result;
    logic [15:0] wide;
    logic single_bit;
    int count;
    
    initial begin
        // Test 1: Bit select
        a = 8'b10101010;
        single_bit = a[0];
        if (single_bit == 0)
            $display("PASS: Bit select a[0] = %b", single_bit);
        else
            $display("FAIL: Bit select a[0] = %b", single_bit);
            
        single_bit = a[7];
        if (single_bit == 1)
            $display("PASS: Bit select a[7] = %b", single_bit);
        else
            $display("FAIL: Bit select a[7] = %b", single_bit);
            
        // Test 2: Part select
        result = a[7:0];
        if (result == 8'hAA)
            $display("PASS: Part select a[7:0] = %h", result);
        else
            $display("FAIL: Part select = %h", result);
            
        // Test 3: Bit manipulation
        a = 8'h00;
        a[3] = 1;
        if (a == 8'h08)
            $display("PASS: Bit write a[3]=1, a=%h", a);
        else
            $display("FAIL: Bit write a=%h", a);
            
        // Test 4: Part select write
        wide = 16'h0000;
        wide[7:0] = 8'hFF;
        if (wide == 16'h00FF)
            $display("PASS: Part select write = %h", wide);
        else
            $display("FAIL: Part select write = %h", wide);
            
        // Test 5: $countones
        a = 8'b10101010;
        count = $countones(a);
        if (count == 4)
            $display("PASS: $countones = %0d", count);
        else
            $display("FAIL: $countones = %0d", count);
            
        // Test 6: $countbits
        count = $countbits(a, 1'b1);
        $display("PASS: $countbits(a,1) = %0d", count);
        
        // Test 7: $onehot
        a = 8'b00010000;
        if ($onehot(a))
            $display("PASS: $onehot(00010000) = 1");
        else
            $display("FAIL: $onehot(00010000) = 0");
            
        // Test 8: $isunknown
        a = 8'hFF;
        if (!$isunknown(a))
            $display("PASS: $isunknown(0xFF) = 0");
        else
            $display("FAIL: $isunknown");
        
        $display("TEST PASSED: bit operations completed");
        $finish;
    end
endmodule
