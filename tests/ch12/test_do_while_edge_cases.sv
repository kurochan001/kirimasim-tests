/*
:name: test_do_while_edge_cases
:description: Do-while loop edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.5 12.8 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_do_while_edge_cases.expected
*/
// IEEE 1800-2023 §12.7.3: Do-while loop edge cases
// Tests for do-while statement

module test_do_while_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int i, sum, count;

    initial begin
        // Test 1: Simple do-while
        test_count++;
        i = 0;
        sum = 0;
        do begin
            sum += i;
            i++;
        end while (i < 5);
        if (sum == 10) begin
            pass_count++;
            $display("Test 1 PASS: Do-while sum = %0d", sum);
        end else begin
            $display("Test 1 FAIL: Sum unexpected = %0d", sum);
        end

        // Test 2: Do-while executes at least once
        test_count++;
        i = 10;
        count = 0;
        do begin
            count++;
        end while (i < 5);
        if (count == 1) begin
            pass_count++;
            $display("Test 2 PASS: At least once = %0d", count);
        end else begin
            $display("Test 2 FAIL: Once unexpected = %0d", count);
        end

        // Test 3: Do-while single iteration
        test_count++;
        i = 4;
        count = 0;
        do begin
            count++;
            i++;
        end while (i < 5);
        if (count == 1) begin
            pass_count++;
            $display("Test 3 PASS: Single iter = %0d", count);
        end else begin
            $display("Test 3 FAIL: Single unexpected = %0d", count);
        end

        // Test 4: Nested do-while
        test_count++;
        sum = 0;
        i = 0;
        do begin
            // j restarts at 0 on each outer pass; an initializer would run only once (6.21).
            int j;
            j = 0;
            do begin
                sum++;
                j++;
            end while (j < 3);
            i++;
        end while (i < 3);
        if (sum == 9) begin
            pass_count++;
            $display("Test 4 PASS: Nested = %0d", sum);
        end else begin
            $display("Test 4 FAIL: Nested unexpected = %0d", sum);
        end

        // Test 5: Do-while with compound condition
        test_count++;
        i = 0;
        count = 0;
        do begin
            count++;
            i += 2;
        end while (i < 10 && count < 5);
        if (count == 5) begin
            pass_count++;
            $display("Test 5 PASS: Compound = %0d", count);
        end else begin
            $display("Test 5 FAIL: Compound unexpected = %0d", count);
        end

        // Test 6: Do-while with break
        test_count++;
        i = 0;
        do begin
            if (i >= 7) break;
            i++;
        end while (i < 100);
        if (i == 7) begin
            pass_count++;
            $display("Test 6 PASS: Break = %0d", i);
        end else begin
            $display("Test 6 FAIL: Break unexpected = %0d", i);
        end

        // Test 7: Do-while decrementing
        test_count++;
        i = 5;
        sum = 0;
        do begin
            sum += i;
            i--;
        end while (i > 0);
        if (sum == 15) begin
            pass_count++;
            $display("Test 7 PASS: Decrement = %0d", sum);
        end else begin
            $display("Test 7 FAIL: Dec unexpected = %0d", sum);
        end

        // Test 8: Do-while with continue
        test_count++;
        i = 0;
        sum = 0;
        do begin
            i++;
            if (i % 2 == 0) continue;
            sum++;
        end while (i < 10);
        if (sum == 5) begin
            pass_count++;
            $display("Test 8 PASS: Continue = %0d", sum);
        end else begin
            $display("Test 8 FAIL: Cont unexpected = %0d", sum);
        end

        // Test 9: False initial condition
        test_count++;
        i = 100;
        count = 0;
        do begin
            count++;
        end while (i < 0);
        if (count == 1) begin
            pass_count++;
            $display("Test 9 PASS: False init = %0d", count);
        end else begin
            $display("Test 9 FAIL: False unexpected = %0d", count);
        end

        // Test 10: Variable condition
        test_count++;
        begin
            static logic cond = 1;
            count = 0;
            do begin
                count++;
                if (count >= 4) cond = 0;
            end while (cond);
            if (count == 4) begin
                pass_count++;
                $display("Test 10 PASS: Var cond = %0d", count);
            end else begin
                $display("Test 10 FAIL: Var unexpected = %0d", count);
            end
        end

        $display("=== Do-While Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
