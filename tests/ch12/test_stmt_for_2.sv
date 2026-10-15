/*
:name: test_stmt_for_2
:description: For loops test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_for_2.expected
*/
// For loops test
module test_for;
    int i, j, sum, result;
    int arr[5];
    int pass_count = 0;

    initial begin
        // Scenario 1: Simple for loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            sum = sum + i;
        end
        if (sum == 10) pass_count++;  // 0+1+2+3+4=10
        else $display("FAIL: Simple for loop sum=%0d", sum);

        // Scenario 2: For loop with step > 1
        sum = 0;
        for (i = 0; i < 10; i = i + 2) begin
            sum = sum + i;
        end
        if (sum == 20) pass_count++;  // 0+2+4+6+8=20
        else $display("FAIL: For loop with step > 1 sum=%0d", sum);

        // Scenario 3: Nested for loops
        sum = 0;
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                sum = sum + 1;
            end
        end
        if (sum == 9) pass_count++;  // 3*3=9
        else $display("FAIL: Nested for loops sum=%0d", sum);

        // Scenario 4: For loop with array
        for (i = 0; i < 5; i++) begin
            arr[i] = i * 10;
        end
        if (arr[0] == 0 && arr[2] == 20 && arr[4] == 40) pass_count++;
        else $display("FAIL: For loop with array");

        // Scenario 5: Countdown for loop
        result = 0;
        for (i = 5; i > 0; i--) begin
            result = result + i;
        end
        if (result == 15) pass_count++;  // 5+4+3+2+1=15
        else $display("FAIL: Countdown for loop result=%0d", result);

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
