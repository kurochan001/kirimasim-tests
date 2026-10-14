/*
:name: test_control_flow_2
:description: Loops with break and continue, and case inside a loop (IEEE 1800-2023 Sections 12.5, 12.7 and 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 12.8 12.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_control_flow_2.expected
*/
// Loops with break and continue, and case inside a loop (IEEE 1800-2023 Sections 12.5, 12.7 and 12.8)
module test_control_flow_2;
    int pass_count = 0;
    int test_count = 0;
    int i, j, k;
    logic done;
    
    initial begin
        // Test nested loops
        test_count++;
        k = 0;
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                k++;
            end
        end
        if (k == 9) pass_count++;
        
        // Test break
        test_count++;
        k = 0;
        for (i = 0; i < 100; i++) begin
            if (i == 5) break;
            k++;
        end
        if (k == 5) pass_count++;
        
        // Test continue
        test_count++;
        k = 0;
        for (i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;
            k++;
        end
        if (k == 5) pass_count++;
        
        // Test while with break
        test_count++;
        i = 0;
        while (1) begin
            i++;
            if (i >= 10) break;
        end
        if (i == 10) pass_count++;
        
        // Test nested break
        test_count++;
        k = 0;
        done = 0;
        for (i = 0; i < 5 && !done; i++) begin
            for (j = 0; j < 5; j++) begin
                k++;
                if (k == 7) begin
                    done = 1;
                    break;
                end
            end
        end
        if (k == 7) pass_count++;
        
        // Test do-while
        test_count++;
        i = 0;
        do begin
            i++;
        end while (i < 5);
        if (i == 5) pass_count++;
        
        // Test repeat
        test_count++;
        i = 0;
        repeat (10) i++;
        if (i == 10) pass_count++;
        
        // Test forever with break
        test_count++;
        i = 0;
        forever begin
            i++;
            if (i == 3) break;
        end
        if (i == 3) pass_count++;
        
        // Test foreach
        test_count++;
        begin
            static int arr[5] = '{1, 2, 3, 4, 5};
            k = 0;
            foreach (arr[idx]) k += arr[idx];
            if (k == 15) pass_count++;
        end
        
        // Test case inside loop
        test_count++;
        k = 0;
        for (i = 0; i < 4; i++) begin
            case (i)
                0: k += 1;
                1: k += 2;
                2: k += 4;
                default: k += 8;
            endcase
        end
        if (k == 15) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
