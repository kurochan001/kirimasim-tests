/*
:name: test_block_scope_shadowing
:description: Variables with the same name in different and nested begin-end blocks (IEEE 1800-2023 Sections 9.3.1, 6.21 and 23.9)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1 6.21 23.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_scope_shadowing.expected
*/
// Variables with the same name in different and nested begin-end blocks
// (IEEE 1800-2023 Sections 9.3.1, 6.21 and 23.9)
module test_block_scope_shadowing;
    int pass_count = 0;

    initial begin
        // T1: Same variable name in different begin/end blocks
        begin
            static int x = 10;
            if (x == 10) begin
                $display("T1a: x = %0d", x);
            end
        end
        begin
            static int x = 20;
            if (x == 20) begin
                $display("T1b: x = %0d", x);
                pass_count++;
            end else
                $display("T1: FAIL - x = %0d (expected 20)", x);
        end

        // T2: Nested begin/end with shadowing
        begin
            static int val = 100;
            begin
                static int val = 200;
                if (val == 200) begin
                    pass_count++;
                    $display("T2: PASS - inner val = %0d", val);
                end else
                    $display("T2: FAIL - inner val = %0d", val);
            end
            // Outer val should still be 100
            if (val == 100) begin
                pass_count++;
                $display("T2b: PASS - outer val = %0d", val);
            end else
                $display("T2b: FAIL - outer val = %0d", val);
        end

        // T3: For loop variable scoping
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) begin
                sum += i;
            end
            if (sum == 10) begin
                $display("T3: PASS - for loop sum = %0d", sum);
                pass_count++;
            end else
                $display("T3: FAIL - sum = %0d", sum);
        end

        // T4: Multiple for loops with same variable name
        begin
            static int sum1 = 0, sum2 = 0;
            for (int i = 0; i < 3; i++) sum1 += i;
            for (int i = 0; i < 4; i++) sum2 += i;
            if (sum1 == 3 && sum2 == 6) begin
                $display("T4: PASS - sums: %0d, %0d", sum1, sum2);
                pass_count++;
            end else
                $display("T4: FAIL - sums: %0d, %0d", sum1, sum2);
        end

        // T5: Array in begin/end block with foreach
        begin
            static int arr[4] = '{10, 20, 30, 40};
            static int total = 0;
            foreach (arr[i]) total += arr[i];
            if (total == 100) begin
                $display("T5: PASS - foreach sum = %0d", total);
                pass_count++;
            end else
                $display("T5: FAIL - total = %0d", total);
        end

        // T6: Same array name in different blocks
        begin
            static int data[3] = '{1, 2, 3};
            static int s = 0;
            foreach (data[i]) s += data[i];
            if (s == 6) begin
                $display("T6a: PASS - data sum = %0d", s);
            end
        end
        begin
            static int data[3] = '{10, 20, 30};
            static int s = 0;
            foreach (data[i]) s += data[i];
            if (s == 60) begin
                $display("T6b: PASS - data sum = %0d", s);
                pass_count++;
            end else
                $display("T6: FAIL - s = %0d (expected 60)", s);
        end

        // T7: Queue in begin/end block
        begin
            static int q[$] = '{5, 10, 15};
            if (q.size() == 3 && q[0] == 5 && q[2] == 15) begin
                $display("T7: PASS - queue: size=%0d [0]=%0d [2]=%0d", q.size(), q[0], q[2]);
                pass_count++;
            end else
                $display("T7: FAIL");
        end

        // T8: String in begin/end block
        begin
            static string s = "hello";
            if (s == "hello" && s.len() == 5) begin
                $display("T8: PASS - string: %s len=%0d", s, s.len());
                pass_count++;
            end else
                $display("T8: FAIL");
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count >= 7)
            $display("PASS: test_block_scope_shadowing");
        else
            $display("FAIL: test_block_scope_shadowing (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
