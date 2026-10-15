/*
:name: test_loops_2
:description: Chapter 12: Procedural programming statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1 12.7.2 12.7.3 12.7.4 12.7.5 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loops_2.expected
*/
// IEEE 1800-2023 Chapter 12: Procedural programming statements
// §12.7 Loop statements

module test_loops;
    int test_count;
    int pass_count;

    int i, sum;
    int arr[5];

    initial begin
        test_count = 0;
        pass_count = 0;

        // §12.7.1 for loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            sum = sum + i;
        end
        test_count++;
        if (sum == 10) pass_count++;  // 0+1+2+3+4 = 10
        else $display("FAIL: for loop - sum=%0d (expected 10)", sum);

        // §12.7.2 repeat loop
        sum = 0;
        repeat (5) begin
            sum = sum + 1;
        end
        test_count++;
        if (sum == 5) pass_count++;
        else $display("FAIL: repeat loop - sum=%0d (expected 5)", sum);

        // §12.7.4 while loop
        sum = 0;
        i = 0;
        while (i < 5) begin
            sum = sum + i;
            i++;
        end
        test_count++;
        if (sum == 10) pass_count++;
        else $display("FAIL: while loop - sum=%0d (expected 10)", sum);

        // §12.7.5 do-while loop
        sum = 0;
        i = 0;
        do begin
            sum = sum + 1;
            i++;
        end while (i < 3);
        test_count++;
        if (sum == 3) pass_count++;
        else $display("FAIL: do-while loop - sum=%0d (expected 3)", sum);

        // §12.7.3 foreach loop
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        arr[4] = 50;
        sum = 0;
        foreach (arr[j]) begin
            sum = sum + arr[j];
        end
        test_count++;
        if (sum == 150) pass_count++;
        else $display("FAIL: foreach loop - sum=%0d (expected 150)", sum);

        // §12.8 break statement
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 5) break;
            sum = sum + 1;
        end
        test_count++;
        if (sum == 5) pass_count++;
        else $display("FAIL: break - sum=%0d (expected 5)", sum);

        // §12.8 continue statement
        sum = 0;
        for (i = 0; i < 5; i++) begin
            if (i == 2) continue;
            sum = sum + i;
        end
        test_count++;
        if (sum == 8) pass_count++;  // 0+1+3+4 = 8 (skip 2)
        else $display("FAIL: continue - sum=%0d (expected 8)", sum);

        $display("Chapter 12.7-8 Loops: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
