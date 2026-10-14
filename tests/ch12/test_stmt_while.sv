/*
:name: test_stmt_while
:description: Test for while loop
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4 12.7.5 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_while.expected
*/
// Test for while loop
// IEEE 1800-2023 §12.7: Loop statements
module test_stmt_while;
    initial begin
        int count;
        int sum;

        // Simple while
        count = 0;
        sum = 0;
        while (count < 5) begin
            sum += count;
            count++;
        end
        if (sum != 10) $display("FAIL: Simple while %0d", sum);

        // While with break
        count = 0;
        while (1) begin
            count++;
            if (count >= 10) break;
        end
        if (count != 10) $display("FAIL: While break %0d", count);

        // While with continue
        sum = 0;
        count = 0;
        while (count < 10) begin
            count++;
            if (count % 2 == 0) continue;
            sum += count;
        end
        if (sum != 25) $display("FAIL: While continue %0d", sum);

        // Do-while
        count = 0;
        do begin
            count++;
        end while (count < 5);
        if (count != 5) $display("FAIL: Do-while %0d", count);

        $display("PASS: While loop");
        $finish;
    end
endmodule
