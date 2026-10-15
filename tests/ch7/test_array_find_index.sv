/*
:name: test_array_find_index
:description: Test: Array find_index method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_find_index.expected
*/
// Test: Array find_index method
module test_array_find_index;
    int arr[5] = '{10, 20, 30, 40, 50};
    int result[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Find indices of elements greater than 25
        result = arr.find_index(x) with (x > 25);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        result.sort();
        if (result.size() == 3 && result[0] == 2 && result[1] == 3 && result[2] == 4) begin
            $display("Test 1 PASS: find_index elements > 25");
            passed++;
        end else begin
            $display("Test 1 FAIL: find_index elements > 25, got size=%0d", result.size());
            failed++;
        end

        // Test 2: Find index of element equal to 30
        result = arr.find_index(x) with (x == 30);
        if (result.size() == 1 && result[0] == 2) begin
            $display("Test 2 PASS: find_index element == 30");
            passed++;
        end else begin
            $display("Test 2 FAIL: find_index element == 30");
            failed++;
        end

        // Test 3: Find index of first element
        result = arr.find_index(x) with (x == 10);
        if (result.size() == 1 && result[0] == 0) begin
            $display("Test 3 PASS: find_index element == 10");
            passed++;
        end else begin
            $display("Test 3 FAIL: find_index element == 10");
            failed++;
        end

        // Test 4: Find no matching indices
        result = arr.find_index(x) with (x > 100);
        if (result.size() == 0) begin
            $display("Test 4 PASS: find_index no matches");
            passed++;
        end else begin
            $display("Test 4 FAIL: find_index no matches");
            failed++;
        end

        // Test 5: Find all indices
        result = arr.find_index(x) with (x > 0);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        result.sort();
        if (result.size() == 5 && result[0] == 0 && result[4] == 4) begin
            $display("Test 5 PASS: find_index all elements");
            passed++;
        end else begin
            $display("Test 5 FAIL: find_index all elements");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
