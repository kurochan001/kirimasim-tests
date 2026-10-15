/*
:name: test_stmt_blocking
:description: Blocking assignments test
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_blocking.expected
*/
// Blocking assignments test
module test_blocking;
    int a, b, c, d, e;
    int pass_count = 0;

    initial begin
        // Scenario 1: Simple blocking assignment
        a = 10;
        if (a == 10) pass_count++;
        else $display("FAIL: Simple blocking assignment");

        // Scenario 2: Chained blocking assignments
        b = 20;
        c = b + 5;
        d = c * 2;
        if (d == 50) pass_count++;
        else $display("FAIL: Chained blocking assignments");

        // Scenario 3: Self-referencing assignment
        e = 5;
        e = e + e;
        if (e == 10) pass_count++;
        else $display("FAIL: Self-referencing assignment");

        // Scenario 4: Multiple assignments in sequence
        a = 1;
        a = 2;
        a = 3;
        if (a == 3) pass_count++;
        else $display("FAIL: Multiple assignments in sequence");

        // Scenario 5: Assignment with expression
        b = (10 + 20) * 2 - 15;
        if (b == 45) pass_count++;
        else $display("FAIL: Assignment with expression");

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
