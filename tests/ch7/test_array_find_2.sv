/*
:name: test_array_find_2
:description: Test: Array find method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_find_2.expected
*/
// Test: Array find method
module test_array_find_2;
    int arr[5] = '{10, 20, 30, 40, 50};
    int result[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Find elements greater than 25
        result = arr.find(x) with (x > 25);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        result.sort();
        if (result.size() == 3 && result[0] == 30 && result[1] == 40 && result[2] == 50) begin
            $display("Test 1 PASS: find elements > 25");
            passed++;
        end else begin
            $display("Test 1 FAIL: find elements > 25, got size=%0d", result.size());
            failed++;
        end

        // Test 2: Find elements equal to 20
        result = arr.find(x) with (x == 20);
        if (result.size() == 1 && result[0] == 20) begin
            $display("Test 2 PASS: find element == 20");
            passed++;
        end else begin
            $display("Test 2 FAIL: find element == 20");
            failed++;
        end

        // Test 3: Find elements less than 15
        result = arr.find(x) with (x < 15);
        if (result.size() == 1 && result[0] == 10) begin
            $display("Test 3 PASS: find elements < 15");
            passed++;
        end else begin
            $display("Test 3 FAIL: find elements < 15");
            failed++;
        end

        // Test 4: Find no matching elements
        result = arr.find(x) with (x > 100);
        if (result.size() == 0) begin
            $display("Test 4 PASS: find no matches");
            passed++;
        end else begin
            $display("Test 4 FAIL: find no matches, got size=%0d", result.size());
            failed++;
        end

        // Test 5: Find all elements (always true)
        result = arr.find(x) with (x > 0);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        result.sort();
        if (result.size() == 5) begin
            $display("Test 5 PASS: find all elements");
            passed++;
        end else begin
            $display("Test 5 FAIL: find all elements");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
