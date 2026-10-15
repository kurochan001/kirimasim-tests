/*
:name: test_stmt_if
:description: If statements test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_if.expected
*/
// If statements test
module test_if;
    int a, b, result;
    int pass_count = 0;

    initial begin
        // Scenario 1: Simple if true condition
        a = 10;
        result = 0;
        if (a > 5) result = 1;
        if (result == 1) pass_count++;
        else $display("FAIL: Simple if true condition");

        // Scenario 2: Simple if false condition
        b = 3;
        result = 0;
        if (b > 5) result = 1;
        if (result == 0) pass_count++;
        else $display("FAIL: Simple if false condition");

        // Scenario 3: If with compound condition (AND)
        a = 10;
        b = 20;
        result = 0;
        if (a > 5 && b > 15) result = 1;
        if (result == 1) pass_count++;
        else $display("FAIL: If with compound condition AND");

        // Scenario 4: If with compound condition (OR)
        a = 3;
        b = 20;
        result = 0;
        if (a > 5 || b > 15) result = 1;
        if (result == 1) pass_count++;
        else $display("FAIL: If with compound condition OR");

        // Scenario 5: Nested if statements
        a = 10;
        b = 20;
        result = 0;
        if (a > 5) begin
            if (b > 15) begin
                result = 1;
            end
        end
        if (result == 1) pass_count++;
        else $display("FAIL: Nested if statements");

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
