/*
:name: test_array_find_last
:description: Test: Array find_last method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_find_last.expected
*/
// Test: Array find_last method
module test_array_find_last;
    int arr[5] = '{10, 20, 30, 40, 50};
    int result[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Find last element greater than 25
        result = arr.find_last(x) with (x > 25);
        if (result.size() == 1 && result[0] == 50) begin
            $display("Test 1 PASS: find_last element > 25");
            passed++;
        end else begin
            $display("Test 1 FAIL: find_last element > 25, got size=%0d, val=%0d", result.size(), result.size() > 0 ? result[0] : -1);
            failed++;
        end

        // Test 2: Find last element less than 35
        result = arr.find_last(x) with (x < 35);
        if (result.size() == 1 && result[0] == 30) begin
            $display("Test 2 PASS: find_last element < 35");
            passed++;
        end else begin
            $display("Test 2 FAIL: find_last element < 35");
            failed++;
        end

        // Test 3: Find last element (should be last in array)
        result = arr.find_last(x) with (x > 0);
        if (result.size() == 1 && result[0] == 50) begin
            $display("Test 3 PASS: find_last any element");
            passed++;
        end else begin
            $display("Test 3 FAIL: find_last any element");
            failed++;
        end

        // Test 4: Find last with no matches
        result = arr.find_last(x) with (x > 100);
        if (result.size() == 0) begin
            $display("Test 4 PASS: find_last no matches");
            passed++;
        end else begin
            $display("Test 4 FAIL: find_last no matches");
            failed++;
        end

        // Test 5: Find last element less than 15
        result = arr.find_last(x) with (x < 15);
        if (result.size() == 1 && result[0] == 10) begin
            $display("Test 5 PASS: find_last element < 15");
            passed++;
        end else begin
            $display("Test 5 FAIL: find_last element < 15");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
