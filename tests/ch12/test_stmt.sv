/*
:name: test_stmt
:description: Procedural statements: if, case, loops, break and continue (IEEE 1800-2023 Sections 12.4 to 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 12.5 12.7 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt.expected
*/
module test_stmt;
    int pass_count = 0;
    int test_count = 0;
    int val, sum, prod;
    logic [7:0] data[8];
    
    initial begin
        // Initialize
        val = 0;
        sum = 0;
        prod = 1;
        for (int j = 0; j < 8; j++) data[j] = j + 1;
        
        // Test 1: Sequential assignments
        test_count++;
        val = 1;
        val = val + 1;
        val = val * 2;
        if (val == 4) pass_count++;
        
        // Test 2: If-else chain
        test_count++;
        val = 50;
        if (val < 25) sum = 1;
        else if (val < 50) sum = 2;
        else if (val <= 50) sum = 3;
        else sum = 4;
        if (sum == 3) pass_count++;
        
        // Test 3: Case statement
        test_count++;
        case (val)
            25: sum = 10;
            50: sum = 20;
            75: sum = 30;
            default: sum = 0;
        endcase
        if (sum == 20) pass_count++;
        
        // Test 4: For loop accumulation
        test_count++;
        sum = 0;
        for (int j = 1; j <= 10; j++) sum += j;
        if (sum == 55) pass_count++;
        
        // Test 5: While loop
        test_count++;
        val = 0;
        while (val < 5) val++;
        if (val == 5) pass_count++;
        
        // Test 6: Do-while
        test_count++;
        val = 10;
        do begin
            val--;
        end while (val > 5);
        if (val == 5) pass_count++;
        
        // Test 7: Foreach with array
        test_count++;
        sum = 0;
        foreach (data[j]) sum += data[j];
        if (sum == 36) pass_count++;
        
        // Test 8: Nested statement
        test_count++;
        sum = 0;
        for (int x = 0; x < 3; x++) begin
            for (int y = 0; y < 3; y++) begin
                if (x == y) sum += x;
            end
        end
        if (sum == 3) pass_count++;
        
        // Test 9: Repeat statement
        test_count++;
        val = 0;
        repeat (7) val++;
        if (val == 7) pass_count++;
        
        // Test 10: Break/continue
        test_count++;
        sum = 0;
        for (int j = 0; j < 20; j++) begin
            if (j == 10) break;
            if (j % 2 == 0) continue;
            sum++;
        end
        if (sum == 5) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
