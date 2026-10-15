/*
:name: test_stmt_repeat_2
:description: Repeat loops test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_repeat_2.expected
*/
// Repeat loops test
module test_repeat;
    int i, sum, result;
    int pass_count = 0;

    initial begin
        // Scenario 1: Simple repeat loop
        sum = 0;
        repeat (5) begin
            sum = sum + 1;
        end
        if (sum == 5) pass_count++;
        else $display("FAIL: Simple repeat loop sum=%0d", sum);

        // Scenario 2: Repeat with accumulation
        i = 1;
        repeat (4) begin
            i = i * 2;
        end
        if (i == 16) pass_count++;  // 1*2*2*2*2=16
        else $display("FAIL: Repeat with accumulation i=%0d", i);

        // Scenario 3: Repeat zero times
        sum = 100;
        repeat (0) begin
            sum = sum + 1;
        end
        if (sum == 100) pass_count++;
        else $display("FAIL: Repeat zero times sum=%0d", sum);

        // Scenario 4: Repeat with variable count
        result = 0;
        i = 3;
        repeat (i) begin
            result = result + 10;
        end
        if (result == 30) pass_count++;
        else $display("FAIL: Repeat with variable count result=%0d", result);

        // Scenario 5: Nested repeat loops
        result = 0;
        repeat (3) begin
            repeat (4) begin
                result = result + 1;
            end
        end
        if (result == 12) pass_count++;  // 3*4=12
        else $display("FAIL: Nested repeat loops result=%0d", result);

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
