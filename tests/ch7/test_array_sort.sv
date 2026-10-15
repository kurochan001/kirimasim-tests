/*
:name: test_array_sort
:description: Array ordering method - sort()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_sort.expected
*/
// IEEE 1800-2023 §7.12.2: Array ordering method - sort()
module test_array_sort;
    int arr[5] = '{5, 2, 8, 1, 9};
    int dyn[];
    int q[$];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        arr.sort();
        if (arr[0] == 1 && arr[1] == 2 && arr[2] == 5 && arr[3] == 8 && arr[4] == 9) begin
            $display("Test 1 PASS: sorted=%0d,%0d,%0d,%0d,%0d", arr[0], arr[1], arr[2], arr[3], arr[4]);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Dynamic array sort
        dyn = '{30, 10, 20, 50, 40};
        dyn.sort();
        if (dyn[0] == 10 && dyn[4] == 50) begin
            $display("Test 2 PASS: dyn sorted");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Queue sort
        q = '{7, 3, 9, 1, 5};
        q.sort();
        if (q[0] == 1 && q[4] == 9) begin
            $display("Test 3 PASS: queue sorted");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Already sorted
        dyn = '{1, 2, 3, 4, 5};
        dyn.sort();
        if (dyn[0] == 1 && dyn[4] == 5) begin
            $display("Test 4 PASS: already sorted");
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: With duplicates
        dyn = '{3, 1, 4, 1, 5};
        dyn.sort();
        if (dyn[0] == 1 && dyn[1] == 1 && dyn[4] == 5) begin
            $display("Test 5 PASS: with duplicates");
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        $display("Passed: %0d/5", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
