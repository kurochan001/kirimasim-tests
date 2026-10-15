/*
:name: test_array_reverse
:description: Array ordering method - reverse()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reverse.expected
*/
// IEEE 1800-2023 §7.12.2: Array ordering method - reverse()
module test_array_reverse;
    int arr[4] = '{1, 2, 3, 4};
    int dyn[];
    int q[$];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        arr.reverse();
        if (arr[0] == 4 && arr[1] == 3 && arr[2] == 2 && arr[3] == 1) begin
            $display("Test 1 PASS: reverse=%0d,%0d,%0d,%0d", arr[0], arr[1], arr[2], arr[3]);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d,%0d,%0d,%0d", arr[0], arr[1], arr[2], arr[3]);
            fail_count++;
        end

        // Test 2: Dynamic array reverse
        dyn = new[5];
        dyn = '{10, 20, 30, 40, 50};
        dyn.reverse();
        if (dyn[0] == 50 && dyn[4] == 10) begin
            $display("Test 2 PASS: dyn reverse first=%0d last=%0d", dyn[0], dyn[4]);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: first=%0d last=%0d", dyn[0], dyn[4]);
            fail_count++;
        end

        // Test 3: Queue reverse
        q = '{100, 200, 300};
        q.reverse();
        if (q[0] == 300 && q[2] == 100) begin
            $display("Test 3 PASS: queue reverse");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Single element reverse
        dyn = '{42};
        dyn.reverse();
        if (dyn[0] == 42) begin
            $display("Test 4 PASS: single element");
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
