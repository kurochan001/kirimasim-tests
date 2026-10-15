/*
:name: test_comb_foreach_3d_break
:description: Test: 3D+ foreach break/continue propagation
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3 12.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_foreach_3d_break.expected
*/
// Test: 3D+ foreach break/continue propagation
// Verifies IEEE 1800-2023 §12.7.3 foreach with break in multi-dimensional arrays
module test_comb_foreach_3d_break;
    int pass_count = 0;

    initial begin
        // T1: 3D foreach with break - exits entire foreach (IEEE 1800-2023 §12.8)
        begin
            int arr[2][3][4];
            static int sum = 0;
            foreach (arr[i,j,k]) arr[i][j][k] = i*100 + j*10 + k;
            foreach (arr[i,j,k]) begin
                if (k == 2) break;
                sum += arr[i][j][k];
            end
            // IEEE 1800-2023 §12.8: break exits nearest enclosing loop (the entire foreach)
            // Iteration: (0,0,0)=0, (0,0,1)=1, then (0,0,2) -> break
            // sum = 0 + 1 = 1
            if (sum == 1) begin
                $display("T1: PASS - 3D foreach break exits entire loop, sum=%0d", sum);
                pass_count++;
            end else begin
                $display("T1: FAIL - sum = %0d (expected 1)", sum);
            end
        end

        // T2: 3D foreach with continue on middle loop
        begin
            int arr[2][3][2];
            static int sum = 0;
            foreach (arr[i,j,k]) arr[i][j][k] = i*100 + j*10 + k;
            foreach (arr[i,j,k]) begin
                if (j == 1) continue;
                sum += arr[i][j][k];
            end
            // Skip j=1: i=0: j=0:(0+1)=1, j=2:(20+21)=41 => 42
            //            i=1: j=0:(100+101)=201, j=2:(120+121)=241 => 442
            // Total = 42 + 442 = 484
            if (sum == 484) begin
                $display("T2: PASS - 3D foreach continue on j");
                pass_count++;
            end else begin
                $display("T2: FAIL - sum = %0d (expected 484)", sum);
            end
        end

        // T3: 2D foreach break on outer loop
        begin
            int arr[4][3];
            static int count = 0;
            foreach (arr[i,j]) arr[i][j] = i*10 + j;
            foreach (arr[i,j]) begin
                count++;
                if (i == 1 && j == 1) break;
            end
            // i=0: j=0,1,2 (3), i=1: j=0,1 (break) => 5
            if (count == 5) begin
                $display("T3: PASS - 2D foreach break at [1][1]");
                pass_count++;
            end else begin
                $display("T3: FAIL - count = %0d (expected 5)", count);
            end
        end

        // T4: foreach on 1D dynamic array with break
        begin
            int dyn[];
            static int sum = 0;
            dyn = new[10];
            foreach (dyn[i]) dyn[i] = i * 3;
            foreach (dyn[i]) begin
                if (dyn[i] > 15) break;
                sum += dyn[i];
            end
            // 0, 3, 6, 9, 12, 15, break at 18 (>15)
            // sum = 0+3+6+9+12+15 = 45
            if (sum == 45) begin
                $display("T4: PASS - dynamic array foreach break");
                pass_count++;
            end else begin
                $display("T4: FAIL - sum = %0d (expected 45)", sum);
            end
        end

        // T5: foreach with nested begin/end and break
        begin
            int arr[3][3];
            static int last_i = -1, last_j = -1;
            foreach (arr[i,j]) arr[i][j] = i + j;
            foreach (arr[i,j]) begin
                last_i = i;
                last_j = j;
                if (arr[i][j] == 3) break;
            end
            // arr[0][0]=0, [0][1]=1, [0][2]=2, [1][0]=1, [1][1]=2, [1][2]=3 => break
            if (last_i == 1 && last_j == 2) begin
                $display("T5: PASS - foreach break at value 3: [%0d][%0d]", last_i, last_j);
                pass_count++;
            end else begin
                $display("T5: FAIL - last=[%0d][%0d] (expected [1][2])", last_i, last_j);
            end
        end

        // T6: foreach on queue with break
        begin
            static int q[$] = '{10, 20, 30, 40, 50};
            static int sum = 0;
            foreach (q[i]) begin
                if (q[i] >= 40) break;
                sum += q[i];
            end
            if (sum == 60) begin
                $display("T6: PASS - queue foreach break");
                pass_count++;
            end else begin
                $display("T6: FAIL - sum = %0d (expected 60)", sum);
            end
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_foreach_3d_break");
        else
            $display("FAIL: test_comb_foreach_3d_break (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
