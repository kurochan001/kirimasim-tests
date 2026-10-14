/*
:name: test_while_edge_cases
:description: While loop edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4 12.8
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_while_edge_cases.expected
*/
// IEEE 1800-2023 §12.7.4: While loop edge cases
// Tests for while statement

module test_while_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int i, sum, count;

    initial begin
        // Test 1: Simple while
        test_count++;
        i = 0;
        sum = 0;
        while (i < 5) begin
            sum += i;
            i++;
        end
        if (sum == 10) begin
            pass_count++;
            $display("Test 1 PASS: While sum = %0d", sum);
        end else begin
            $display("Test 1 FAIL: Sum unexpected = %0d", sum);
        end

        // Test 2: While never executes
        test_count++;
        i = 10;
        count = 0;
        while (i < 5) begin
            count++;
            i++;
        end
        if (count == 0) begin
            pass_count++;
            $display("Test 2 PASS: Never exec = %0d", count);
        end else begin
            $display("Test 2 FAIL: Never unexpected = %0d", count);
        end

        // Test 3: While single iteration
        test_count++;
        i = 4;
        count = 0;
        while (i < 5) begin
            count++;
            i++;
        end
        if (count == 1) begin
            pass_count++;
            $display("Test 3 PASS: Single iter = %0d", count);
        end else begin
            $display("Test 3 FAIL: Single unexpected = %0d", count);
        end

        // Test 4: Nested while
        test_count++;
        sum = 0;
        i = 0;
        while (i < 3) begin
            // A declaration initializer would run only once (6.21), so j is
            // reset by an assignment on every outer iteration.
            int j;
            j = 0;
            while (j < 3) begin
                sum++;
                j++;
            end
            i++;
        end
        if (sum == 9) begin
            pass_count++;
            $display("Test 4 PASS: Nested = %0d", sum);
        end else begin
            $display("Test 4 FAIL: Nested = %0d", sum);
        end

        // Test 5: While with compound condition
        test_count++;
        i = 0;
        count = 0;
        while (i < 10 && count < 5) begin
            count++;
            i += 2;
        end
        if (count == 5) begin
            pass_count++;
            $display("Test 5 PASS: Compound = %0d", count);
        end else begin
            $display("Test 5 FAIL: Compound unexpected = %0d", count);
        end

        // Test 6: While with break
        test_count++;
        i = 0;
        while (i < 100) begin
            if (i >= 7) break;
            i++;
        end
        if (i == 7) begin
            pass_count++;
            $display("Test 6 PASS: Break = %0d", i);
        end else begin
            $display("Test 6 FAIL: Break unexpected = %0d", i);
        end

        // Test 7: While decrementing
        test_count++;
        i = 5;
        sum = 0;
        while (i > 0) begin
            sum += i;
            i--;
        end
        if (sum == 15) begin
            pass_count++;
            $display("Test 7 PASS: Decrement = %0d", sum);
        end else begin
            $display("Test 7 FAIL: Dec unexpected = %0d", sum);
        end

        // Test 8: While with continue
        test_count++;
        i = 0;
        sum = 0;
        while (i < 10) begin
            i++;
            if (i % 2 == 0) continue;
            sum++;
        end
        if (sum == 5) begin
            pass_count++;
            $display("Test 8 PASS: Continue = %0d", sum);
        end else begin
            $display("Test 8 FAIL: Cont unexpected = %0d", sum);
        end

        // Test 9: While(1) with break
        test_count++;
        i = 0;
        while (1) begin
            i++;
            if (i >= 3) break;
        end
        if (i == 3) begin
            pass_count++;
            $display("Test 9 PASS: While(1) = %0d", i);
        end else begin
            $display("Test 9 FAIL: While1 unexpected = %0d", i);
        end

        // Test 10: Variable condition
        test_count++;
        begin
            static logic cond = 1;
            count = 0;
            while (cond) begin
                count++;
                if (count >= 4) cond = 0;
            end
            if (count == 4) begin
                pass_count++;
                $display("Test 10 PASS: Var cond = %0d", count);
            end else begin
                $display("Test 10 FAIL: Var unexpected = %0d", count);
            end
        end

        $display("=== While Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
