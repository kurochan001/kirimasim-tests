/*
:name: test_assignment_ops
:description: Test 1: Simple assignment
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.4.2 11.4.3 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_ops.expected
*/
// IEEE 1800-2023 Section 10

module test_assignment_ops;
    int a, b;
    logic [7:0] lv;
    
    initial begin
        // Test 1: Simple assignment
        a = 100;
        if (a == 100)
            $display("PASS: Simple assignment a=%0d", a);
        else
            $display("FAIL: Simple = %0d", a);
            
        // Test 2: Add assignment
        a = 10;
        a = a + 5;
        if (a == 15)
            $display("PASS: Add result=%0d", a);
        else
            $display("FAIL: Add result=%0d", a);
            
        // Test 3: Subtract
        a = 20;
        a = a - 8;
        if (a == 12)
            $display("PASS: Subtract result=%0d", a);
        else
            $display("FAIL: Subtract result=%0d", a);
            
        // Test 4: Multiply
        a = 5;
        a = a * 3;
        if (a == 15)
            $display("PASS: Multiply result=%0d", a);
        else
            $display("FAIL: Multiply result=%0d", a);
            
        // Test 5: Divide
        a = 20;
        a = a / 4;
        if (a == 5)
            $display("PASS: Divide result=%0d", a);
        else
            $display("FAIL: Divide result=%0d", a);
            
        // Test 6: Bitwise AND
        lv = 8'hFF;
        lv = lv & 8'h0F;
        if (lv == 8'h0F)
            $display("PASS: Bitwise AND result=%h", lv);
        else
            $display("FAIL: AND result=%h", lv);
            
        // Test 7: Bitwise OR
        lv = 8'hF0;
        lv = lv | 8'h0F;
        if (lv == 8'hFF)
            $display("PASS: Bitwise OR result=%h", lv);
        else
            $display("FAIL: OR result=%h", lv);
            
        // Test 8: Increment/Decrement
        a = 5;
        a++;
        if (a == 6)
            $display("PASS: Increment a++=%0d", a);
        else
            $display("FAIL: a++=%0d", a);
            
        a--;
        if (a == 5)
            $display("PASS: Decrement a--=%0d", a);
        else
            $display("FAIL: a--=%0d", a);
        
        $display("TEST PASSED: assignment operations completed");
        $finish;
    end
endmodule
