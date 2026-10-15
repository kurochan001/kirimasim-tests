/*
:name: test_assoc_prev_2
:description: Test: Associative array prev method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.7 7.9.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_prev_2.expected
*/
// Test: Associative array prev method
module test_assoc_prev_2;
    int aa[string];
    int num_aa[int];
    string key;
    int ikey;
    int result;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Setup and get last, then prev
        aa["apple"] = 1;
        aa["banana"] = 2;
        aa["cherry"] = 3;
        result = aa.last(key);
        result = aa.prev(key);
        if (result == 1 && key == "banana") begin
            $display("Test 1 PASS: prev after last");
            passed++;
        end else begin
            $display("Test 1 FAIL: prev after last, got %s", key);
            failed++;
        end

        // Test 2: Prev to first entry
        result = aa.prev(key);
        if (result == 1 && key == "apple") begin
            $display("Test 2 PASS: prev to first");
            passed++;
        end else begin
            $display("Test 2 FAIL: prev to first");
            failed++;
        end

        // Test 3: Prev at beginning returns 0
        result = aa.prev(key);
        if (result == 0) begin
            $display("Test 3 PASS: prev at beginning returns 0");
            passed++;
        end else begin
            $display("Test 3 FAIL: prev at beginning");
            failed++;
        end

        // Test 4: Integer key prev
        num_aa[10] = 1;
        num_aa[20] = 2;
        num_aa[30] = 3;
        result = num_aa.last(ikey);
        result = num_aa.prev(ikey);
        if (result == 1 && ikey == 20) begin
            $display("Test 4 PASS: integer key prev");
            passed++;
        end else begin
            $display("Test 4 FAIL: integer key prev, got %0d", ikey);
            failed++;
        end

        // Test 5: Full reverse iteration count
        aa.delete();
        aa["a"] = 1;
        aa["b"] = 2;
        aa["c"] = 3;
        aa["d"] = 4;
        begin
            static int count = 0;
            result = aa.last(key);
            while (result) begin
                count++;
                result = aa.prev(key);
            end
            if (count == 4) begin
                $display("Test 5 PASS: full reverse iteration count");
                passed++;
            end else begin
                $display("Test 5 FAIL: full reverse iteration count, got %0d", count);
                failed++;
            end
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
