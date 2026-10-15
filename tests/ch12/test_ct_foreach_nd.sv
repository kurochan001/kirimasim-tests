/*
:name: test_ct_foreach_nd
:description: T1: 2D foreach
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3 12.7 12.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ct_foreach_nd.expected
*/
module test_ct_foreach_nd;
    int pass_count = 0;
    int test_count = 15;

    initial begin
        // T1: 2D foreach
        begin
            int arr[3][4];
            static int total = 0;
            for (int i = 0; i < 3; i++)
                for (int j = 0; j < 4; j++)
                    arr[i][j] = i * 4 + j;
            foreach (arr[i, j])
                total += arr[i][j];
            if (total == 66) begin
                $display("T1: PASS - 2D foreach total=%0d", total);
                pass_count++;
            end else
                $display("T1: FAIL - total=%0d", total);
        end

        // T2: 3D foreach
        begin
            int arr[2][2][2];
            static int total = 0;
            for (int i = 0; i < 2; i++)
                for (int j = 0; j < 2; j++)
                    for (int k = 0; k < 2; k++)
                        arr[i][j][k] = i * 4 + j * 2 + k;
            foreach (arr[i, j, k])
                total += arr[i][j][k];
            if (total == 28) begin
                $display("T2: PASS - 3D foreach total=%0d", total);
                pass_count++;
            end else
                $display("T2: FAIL - total=%0d", total);
        end

        // T3: foreach with break
        begin
            int arr[10];
            static int count = 0;
            for (int i = 0; i < 10; i++) arr[i] = i;
            foreach (arr[i]) begin
                if (arr[i] >= 5) break;
                count++;
            end
            if (count == 5) begin
                $display("T3: PASS - foreach break count=%0d", count);
                pass_count++;
            end else
                $display("T3: FAIL - count=%0d", count);
        end

        // T4: foreach with continue
        begin
            int arr[10];
            static int sum = 0;
            for (int i = 0; i < 10; i++) arr[i] = i;
            foreach (arr[i]) begin
                if (arr[i] % 2 != 0) continue;
                sum += arr[i];
            end
            if (sum == 20) begin
                $display("T4: PASS - foreach continue sum=%0d", sum);
                pass_count++;
            end else
                $display("T4: FAIL - sum=%0d", sum);
        end

        // T5: foreach on queue
        begin
            static int q[$] = '{10, 20, 30, 40, 50};
            static int sum = 0;
            foreach (q[i])
                sum += q[i];
            if (sum == 150) begin
                $display("T5: PASS - foreach queue sum=%0d", sum);
                pass_count++;
            end else
                $display("T5: FAIL - sum=%0d", sum);
        end

        // T6: foreach on assoc array
        begin
            int aa[string];
            static int sum = 0;
            aa["a"] = 1;
            aa["b"] = 2;
            aa["c"] = 3;
            foreach (aa[key])
                sum += aa[key];
            if (sum == 6) begin
                $display("T6: PASS - foreach assoc sum=%0d", sum);
                pass_count++;
            end else
                $display("T6: FAIL - sum=%0d", sum);
        end

        // T7: foreach on dynamic array
        begin
            int da[];
            static int sum = 0;
            da = new[4];
            da[0] = 5; da[1] = 10; da[2] = 15; da[3] = 20;
            foreach (da[i])
                sum += da[i];
            if (sum == 50) begin
                $display("T7: PASS - foreach dynarray sum=%0d", sum);
                pass_count++;
            end else
                $display("T7: FAIL - sum=%0d", sum);
        end

        // T8: do-while loop
        begin
            static int i = 0;
            static int sum = 0;
            do begin
                sum += i;
                i++;
            end while (i < 5);
            if (sum == 10) begin
                $display("T8: PASS - do-while sum=%0d", sum);
                pass_count++;
            end else
                $display("T8: FAIL - sum=%0d", sum);
        end

        // T9: repeat loop
        begin
            static int count = 0;
            repeat (10) count++;
            if (count == 10) begin
                $display("T9: PASS - repeat count=%0d", count);
                pass_count++;
            end else
                $display("T9: FAIL - count=%0d", count);
        end

        // T10: Multi-variable for init
        begin
            static int sum = 0;
            for (int i = 0, int j = 10; i < 5; i++, j--) begin
                sum += i + j;
            end
            if (sum == 50) begin
                $display("T10: PASS - multi-var for sum=%0d", sum);
                pass_count++;
            end else
                $display("T10: FAIL - sum=%0d", sum);
        end

        // T11: forever with break
        begin
            static int count = 0;
            forever begin
                if (count >= 7) break;
                count++;
            end
            if (count == 7) begin
                $display("T11: PASS - forever+break count=%0d", count);
                pass_count++;
            end else
                $display("T11: FAIL - count=%0d", count);
        end

        // T12: Nested foreach with mixed containers
        begin
            int arr[2][$];
            static int total = 0;
            arr[0] = '{1, 2, 3};
            arr[1] = '{4, 5};
            foreach (arr[i]) begin
                foreach (arr[i][j]) begin
                    total += arr[i][j];
                end
            end
            if (total == 15) begin
                $display("T12: PASS - nested foreach mixed total=%0d", total);
                pass_count++;
            end else
                $display("T12: FAIL - total=%0d", total);
        end

        // T13: while with complex condition
        begin
            static int a = 0, b = 100;
            while (a < 50 && b > 60) begin
                a += 10;
                b -= 8;
            end
            if (a == 50) begin
                $display("T13: PASS - while complex a=%0d b=%0d", a, b);
                pass_count++;
            end else
                $display("T13: FAIL - a=%0d b=%0d", a, b);
        end

        // T14: foreach with modification
        begin
            static int arr[5] = '{1, 2, 3, 4, 5};
            foreach (arr[i])
                arr[i] *= 2;
            if (arr[0] == 2 && arr[2] == 6 && arr[4] == 10) begin
                $display("T14: PASS - foreach modify");
                pass_count++;
            end else
                $display("T14: FAIL");
        end

        // T15: Nested for loops with early termination
        begin
            static int found_i = -1, found_j = -1;
            int matrix[3][3];
            matrix[0][0] = 1; matrix[0][1] = 2; matrix[0][2] = 3;
            matrix[1][0] = 4; matrix[1][1] = 42; matrix[1][2] = 6;
            matrix[2][0] = 7; matrix[2][1] = 8; matrix[2][2] = 9;
            for (int i = 0; i < 3 && found_i == -1; i++)
                for (int j = 0; j < 3 && found_j == -1; j++)
                    if (matrix[i][j] == 42) begin
                        found_i = i; found_j = j;
                    end
            if (found_i == 1 && found_j == 1) begin
                $display("T15: PASS - nested search found at [%0d][%0d]", found_i, found_j);
                pass_count++;
            end else
                $display("T15: FAIL - found at [%0d][%0d]", found_i, found_j);
        end

        $display("pass_count = %0d / %0d", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS: test_ct_foreach_nd");
        else
            $display("FAIL: test_ct_foreach_nd (pass_count=%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
