/*
:name: test_array_shuffle
:description: Array ordering method - shuffle()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_shuffle.expected
*/
// IEEE 1800-2023 §7.12.2: Array ordering method - shuffle()
module test_array_shuffle;
    int arr[5] = '{1, 2, 3, 4, 5};
    int dyn[];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int sum_before, sum_after;

        sum_before = arr.sum();
        arr.shuffle();
        sum_after = arr.sum();
        if (sum_before == sum_after) begin
            $display("Test 1 PASS: shuffle preserves sum=%0d", sum_after);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: sum changed from %0d to %0d", sum_before, sum_after);
            fail_count++;
        end

        // Test 2: Dynamic array shuffle
        dyn = '{10, 20, 30, 40, 50};
        sum_before = dyn.sum();
        dyn.shuffle();
        sum_after = dyn.sum();
        if (sum_before == sum_after) begin
            $display("Test 2 PASS: dyn shuffle preserves sum=%0d", sum_after);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Single element shuffle (no change)
        dyn = '{42};
        dyn.shuffle();
        if (dyn[0] == 42) begin
            $display("Test 3 PASS: single element unchanged");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Empty array shuffle (no crash)
        dyn = new[0];
        dyn.shuffle();
        if (dyn.size() == 0) begin
            $display("Test 4 PASS: empty shuffle ok");
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
