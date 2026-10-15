/*
:name: test_array_rsort
:description: Array ordering method - rsort()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_rsort.expected
*/
// IEEE 1800-2023 §7.12.2: Array ordering method - rsort()
module test_array_rsort;
    int arr[5] = '{5, 2, 8, 1, 9};
    int dyn[];
    int q[$];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        arr.rsort();
        if (arr[0] == 9 && arr[1] == 8 && arr[2] == 5 && arr[3] == 2 && arr[4] == 1) begin
            $display("Test 1 PASS: rsorted=%0d,%0d,%0d,%0d,%0d", arr[0], arr[1], arr[2], arr[3], arr[4]);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Dynamic array rsort
        dyn = '{30, 10, 20, 50, 40};
        dyn.rsort();
        if (dyn[0] == 50 && dyn[4] == 10) begin
            $display("Test 2 PASS: dyn rsorted");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Queue rsort
        q = '{7, 3, 9, 1, 5};
        q.rsort();
        if (q[0] == 9 && q[4] == 1) begin
            $display("Test 3 PASS: queue rsorted");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Already reverse sorted
        dyn = '{5, 4, 3, 2, 1};
        dyn.rsort();
        if (dyn[0] == 5 && dyn[4] == 1) begin
            $display("Test 4 PASS: already rsorted");
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
