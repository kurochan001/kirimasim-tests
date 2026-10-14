/*
:name: test_stmt_break
:description: Break statement test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_break.expected
*/
// Break statement test
module test_break;
    int i, j, sum, result;
    int pass_count = 0;

    initial begin
        // Scenario 1: Break in for loop
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 5) break;
            sum = sum + i;
        end
        if (sum == 10 && i == 5) pass_count++;  // 0+1+2+3+4=10
        else $display("FAIL: Break in for loop sum=%0d i=%0d", sum, i);

        // Scenario 2: Break in while loop
        i = 0;
        sum = 0;
        while (i < 100) begin
            if (sum >= 15) break;
            sum = sum + i;
            i++;
        end
        if (sum == 15) pass_count++;  // 0+1+2+3+4+5
        else $display("FAIL: Break in while loop sum=%0d", sum);

        // Scenario 3: Break in nested loop (inner)
        result = 0;
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 5; j++) begin
                if (j == 2) break;
                result++;
            end
        end
        if (result == 10) pass_count++;  // 5 outer loops * 2 inner iterations
        else $display("FAIL: Break in nested loop inner result=%0d", result);

        // Scenario 4: Break with condition at start
        sum = 0;
        for (i = 10; i < 20; i++) begin
            if (i == 10) break;
            sum = sum + 1;
        end
        if (sum == 0) pass_count++;
        else $display("FAIL: Break with condition at start sum=%0d", sum);

        // Scenario 5: Multiple breaks in same loop
        result = 0;
        for (i = 0; i < 10; i++) begin
            result++;
            if (i == 3) break;
            if (i == 7) break;  // Never reached
        end
        if (result == 4) pass_count++;  // i=0,1,2,3 then break
        else $display("FAIL: Multiple breaks in same loop result=%0d", result);

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
