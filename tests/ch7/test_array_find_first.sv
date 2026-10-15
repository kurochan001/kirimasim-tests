/*
:name: test_array_find_first
:description: Test: Array find_first method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_find_first.expected
*/
// Test: Array find_first method
module test_array_find_first;
    int arr[5] = '{10, 20, 30, 40, 50};
    int result[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Find first element greater than 25
        result = arr.find_first(x) with (x > 25);
        if (result.size() == 1 && result[0] == 30) begin
            $display("Test 1 PASS: find_first element > 25");
            passed++;
        end else begin
            $display("Test 1 FAIL: find_first element > 25, got size=%0d", result.size());
            failed++;
        end

        // Test 2: Find first element equal to 20
        result = arr.find_first(x) with (x == 20);
        if (result.size() == 1 && result[0] == 20) begin
            $display("Test 2 PASS: find_first element == 20");
            passed++;
        end else begin
            $display("Test 2 FAIL: find_first element == 20");
            failed++;
        end

        // Test 3: Find first element (should be first in array)
        result = arr.find_first(x) with (x > 0);
        if (result.size() == 1 && result[0] == 10) begin
            $display("Test 3 PASS: find_first any element");
            passed++;
        end else begin
            $display("Test 3 FAIL: find_first any element");
            failed++;
        end

        // Test 4: Find first with no matches
        result = arr.find_first(x) with (x > 100);
        if (result.size() == 0) begin
            $display("Test 4 PASS: find_first no matches");
            passed++;
        end else begin
            $display("Test 4 FAIL: find_first no matches");
            failed++;
        end

        // Test 5: Find first element greater than 45
        result = arr.find_first(x) with (x > 45);
        if (result.size() == 1 && result[0] == 50) begin
            $display("Test 5 PASS: find_first element > 45");
            passed++;
        end else begin
            $display("Test 5 FAIL: find_first element > 45");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
