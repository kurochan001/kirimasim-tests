/*
:name: test_stmt_if_else_2
:description: If-else statements test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_if_else_2.expected
*/
// If-else statements test
module test_if_else;
    int a, b, result;
    int pass_count = 0;

    initial begin
        // Scenario 1: If-else taking if branch
        a = 10;
        if (a > 5)
            result = 1;
        else
            result = 0;
        if (result == 1) pass_count++;
        else $display("FAIL: If-else taking if branch");

        // Scenario 2: If-else taking else branch
        a = 3;
        if (a > 5)
            result = 1;
        else
            result = 0;
        if (result == 0) pass_count++;
        else $display("FAIL: If-else taking else branch");

        // Scenario 3: If-else-if chain
        a = 15;
        if (a < 10)
            result = 1;
        else if (a < 20)
            result = 2;
        else
            result = 3;
        if (result == 2) pass_count++;
        else $display("FAIL: If-else-if chain");

        // Scenario 4: Nested if-else
        a = 10;
        b = 5;
        if (a > 5) begin
            if (b > 10)
                result = 1;
            else
                result = 2;
        end else begin
            result = 3;
        end
        if (result == 2) pass_count++;
        else $display("FAIL: Nested if-else");

        // Scenario 5: Multiple else-if branches
        a = 75;
        if (a >= 90)
            result = 5;
        else if (a >= 80)
            result = 4;
        else if (a >= 70)
            result = 3;
        else if (a >= 60)
            result = 2;
        else
            result = 1;
        if (result == 3) pass_count++;
        else $display("FAIL: Multiple else-if branches");

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
