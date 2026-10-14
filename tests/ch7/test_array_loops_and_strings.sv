/*
:name: test_array_loops_and_strings
:description: Array loops, foreach, string length and concatenation (IEEE 1800-2023 Sections 7.4, 12.7.3 and 6.16)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 12.7.3 6.16
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_loops_and_strings.expected
*/
// Array loops, foreach, string length and concatenation (IEEE 1800-2023 Sections 7.4, 12.7.3 and 6.16)
module test_array_loops_and_strings;
    int pass_count = 0;
    int test_count = 0;
    logic [7:0] data;
    int arr[10];
    string str;
    
    initial begin
        // Test 1: Initialize array
        test_count++;
        for (int j = 0; j < 10; j++) arr[j] = j * 2;
        if (arr[5] == 10) pass_count++;
        
        // Test 2: Array sum
        test_count++;
        begin
            static int sum = 0;
            foreach (arr[j]) sum += arr[j];
            if (sum == 90) pass_count++;
        end
        
        // Test 3: Array find
        test_count++;
        begin
            static int found = -1;
            foreach (arr[j]) if (arr[j] == 8) found = j;
            if (found == 4) pass_count++;
        end
        
        // Test 4: Data manipulation
        test_count++;
        data = 8'hAB;
        data = data ^ 8'hFF;
        if (data == 8'h54) pass_count++;
        
        // Test 5: String operation
        test_count++;
        str = "hello";
        if (str.len() == 5) pass_count++;
        
        // Test 6: String concatenation
        test_count++;
        str = {str, " world"};
        if (str == "hello world") pass_count++;
        
        // Test 7: Conditional array
        test_count++;
        begin
            static int count = 0;
            foreach (arr[j]) if (arr[j] > 5) count++;
            if (count == 7) pass_count++;
        end
        
        // Test 8: Array modify
        test_count++;
        arr[0] = 100;
        if (arr[0] == 100) pass_count++;
        
        // Test 9: Nested loop
        test_count++;
        begin
            static int total = 0;
            for (int x = 0; x < 3; x++)
                for (int y = 0; y < 3; y++)
                    total++;
            if (total == 9) pass_count++;
        end
        
        // Test 10: Break in loop
        test_count++;
        begin
            static int idx = -1;
            for (int j = 0; j < 10; j++) begin
                if (arr[j] == 100) begin
                    idx = j;
                    break;
                end
            end
            if (idx == 0) pass_count++;
        end
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
