/*
:name: test_break_continue
:description: Break and continue
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_continue.expected
*/
// IEEE 1800-2023 Section 12.8: Break and continue
module test_break_continue;
    int i, sum;

    initial begin
        // Break in for loop
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 5) break;
            sum = sum + 1;
        end
        if (sum == 5)  // 0,1,2,3,4 then break
            $display("PASS: break in for");
        else
            $display("FAIL: break = %0d", sum);

        // Continue in for loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            if (i == 2) continue;
            sum = sum + i;
        end
        if (sum == 8)  // 0+1+3+4, skip 2
            $display("PASS: continue in for");
        else
            $display("FAIL: continue = %0d", sum);

        // Break in while (with bounded condition)
        i = 0;
        sum = 0;
        while (i < 100) begin
            if (i >= 5) break;
            sum = sum + i;
            i = i + 1;
        end
        if (sum == 10)  // 0+1+2+3+4
            $display("PASS: break in while");
        else
            $display("FAIL: while = %0d", sum);

        // Continue in while
        i = 0;
        sum = 0;
        while (i < 5) begin
            i = i + 1;
            if (i == 3) continue;
            sum = sum + i;
        end
        if (sum == 12)  // 1+2+4+5, skip 3
            $display("PASS: continue in while");
        else
            $display("FAIL: while cont = %0d", sum);

        $display("TEST PASSED: break/continue tests completed");
        $finish;
    end
endmodule
