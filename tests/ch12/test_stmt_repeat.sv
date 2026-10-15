/*
:name: test_stmt_repeat
:description: Test for repeat loop
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_repeat.expected
*/
// Test for repeat loop
// IEEE 1800-2023 §12.7.2: Repeat loop
module test_stmt_repeat;
    initial begin
        int count;
        int sum;

        // Simple repeat
        count = 0;
        repeat (5) begin
            count++;
        end
        if (count != 5) $display("FAIL: Simple repeat %0d", count);

        // Repeat with variable
        sum = 0;
        count = 0;
        repeat (3) begin
            sum += count;
            count++;
        end
        if (sum != 3) $display("FAIL: Repeat variable %0d", sum);

        // Nested repeat
        count = 0;
        repeat (3) begin
            repeat (4) begin
                count++;
            end
        end
        if (count != 12) $display("FAIL: Nested repeat %0d", count);

        // Repeat with expression
        count = 0;
        repeat (2 + 3) begin
            count++;
        end
        if (count != 5) $display("FAIL: Repeat expr %0d", count);

        $display("PASS: Repeat loop");
        $finish;
    end
endmodule
