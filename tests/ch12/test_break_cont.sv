/*
:name: test_break_cont
:description: Test: Break/continue
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_cont.expected
*/
// Test: Break/continue
module test_break_cont;
    int sum1, sum2;
    
    initial begin
        sum1 = 0;
        sum2 = 0;
        
        // Break test
        for (int i = 0; i < 100; i++) begin
            sum1 += i;
            if (i >= 9) break;
        end
        
        // Continue test
        for (int i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;
            sum2 += i;  // Only odd numbers
        end
        
        if (sum1 == 45 && sum2 == 25)
            $display("PASS: Break cont test");
        else
            $display("FAIL: sum1=%0d sum2=%0d", sum1, sum2);
        $finish;
    end
endmodule
