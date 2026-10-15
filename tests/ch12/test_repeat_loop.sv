/*
:name: test_repeat_loop
:description: Repeat loops
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4 12.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_repeat_loop.expected
*/
// IEEE 1800-2023 Section 12.7.4: Repeat loops
module test_repeat_loop;
    int sum, count;

    initial begin
        // Basic repeat
        sum = 0;
        repeat (5)
            sum = sum + 1;
        if (sum == 5)
            $display("PASS: basic repeat");
        else
            $display("FAIL: repeat = %0d", sum);

        // Repeat with variable
        count = 3;
        sum = 0;
        repeat (count)
            sum = sum + 10;
        if (sum == 30)
            $display("PASS: repeat var");
        else
            $display("FAIL: var = %0d", sum);

        // Repeat zero
        sum = 0;
        repeat (0)
            sum = sum + 1;
        if (sum == 0)
            $display("PASS: repeat zero");
        else
            $display("FAIL: zero = %0d", sum);

        // Nested repeat
        sum = 0;
        repeat (3)
            repeat (4)
                sum = sum + 1;
        if (sum == 12)
            $display("PASS: nested repeat");
        else
            $display("FAIL: nested = %0d", sum);

        $display("TEST PASSED: repeat loop tests completed");
        $finish;
    end
endmodule
