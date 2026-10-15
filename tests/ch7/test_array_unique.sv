/*
:name: test_array_unique
:description: Array locator method - unique()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_unique.expected
*/
// IEEE 1800-2023 §7.12.1: Array locator method - unique()
module test_array_unique;
    int arr[6] = '{1, 2, 2, 3, 3, 3};
    int dyn[];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int result[];

        result = arr.unique();
        if (result.size() == 3 && result[0] == 1 && result[1] == 2 && result[2] == 3) begin
            $display("Test 1 PASS: unique size=%0d", result.size());
            pass_count++;
        end else begin
            $display("Test 1 FAIL: unexpected result size=%0d", result.size());
            fail_count++;
        end

        // Test 2: All same values
        dyn = '{5, 5, 5, 5};
        result = dyn.unique();
        if (result.size() == 1 && result[0] == 5) begin
            $display("Test 2 PASS: all same unique=%0d", result[0]);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: size=%0d", result.size());
            fail_count++;
        end

        // Test 3: All different
        dyn = '{1, 2, 3, 4};
        result = dyn.unique();
        if (result.size() == 4) begin
            $display("Test 3 PASS: all different size=%0d", result.size());
            pass_count++;
        end else begin
            $display("Test 3 FAIL: size=%0d", result.size());
            fail_count++;
        end

        // Test 4: Two element unique
        dyn = '{7, 7};
        result = dyn.unique();
        if (result.size() == 1 && result[0] == 7) begin
            $display("Test 4 PASS: two same=%0d", result[0]);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: size=%0d", result.size());
            fail_count++;
        end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
