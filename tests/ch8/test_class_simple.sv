/*
:name: test_class_simple
:description: Class Simple Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_simple.expected
*/
// IEEE 1800-2023 Sections 8.4 and 8.6 - Class Simple Tests
module test_class_simple;
    int pass_count = 0;
    int fail_count = 0;
    
    class Counter;
        int count;
        
        function new();
            count = 0;
        endfunction
        
        function void increment();
            count = count + 1;
        endfunction
        
        function int get_count();
            return count;
        endfunction
        
        function void set_count(int val);
            count = val;
        endfunction
    endclass
    
    initial begin
        Counter c1, c2;
        
        $display("=== IEEE 1800-2023 Class Simple Tests ===");
        
        // Test 1: Create
        $display("Test 1: Create");
        c1 = new();
        if (c1.get_count() == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Increment
        $display("Test 2: Increment");
        c1.increment();
        if (c1.get_count() == 1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: Multiple inc
        $display("Test 3: Multiple");
        c1.increment();
        c1.increment();
        if (c1.get_count() == 3) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: Set count
        $display("Test 4: Set");
        c1.set_count(100);
        if (c1.get_count() == 100) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end
        
        // Test 5: Second instance
        $display("Test 5: Second");
        c2 = new();
        if (c2.get_count() == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Independence
        $display("Test 6: Independence");
        c2.set_count(50);
        if (c1.get_count() == 100 && c2.get_count() == 50) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: Reset
        $display("Test 7: Reset");
        c1.set_count(0);
        if (c1.get_count() == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Chain ops
        $display("Test 8: Chain");
        c2.set_count(10);
        c2.increment();
        c2.increment();
        if (c2.get_count() == 12) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
