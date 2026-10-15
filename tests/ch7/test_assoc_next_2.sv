/*
:name: test_assoc_next_2
:description: Test: Associative array next method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.6 7.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_next_2.expected
*/
// Test: Associative array next method
module test_assoc_next_2;
    int aa[string];
    int num_aa[int];
    string key;
    int ikey;
    int result;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Setup and get first, then next
        aa["apple"] = 1;
        aa["banana"] = 2;
        aa["cherry"] = 3;
        result = aa.first(key);
        result = aa.next(key);
        if (result == 1 && key == "banana") begin
            $display("Test 1 PASS: next after first");
            passed++;
        end else begin
            $display("Test 1 FAIL: next after first, got %s", key);
            failed++;
        end

        // Test 2: Next to last entry
        result = aa.next(key);
        if (result == 1 && key == "cherry") begin
            $display("Test 2 PASS: next to last");
            passed++;
        end else begin
            $display("Test 2 FAIL: next to last");
            failed++;
        end

        // Test 3: Next at end returns 0
        result = aa.next(key);
        if (result == 0) begin
            $display("Test 3 PASS: next at end returns 0");
            passed++;
        end else begin
            $display("Test 3 FAIL: next at end");
            failed++;
        end

        // Test 4: Integer key iteration
        num_aa[10] = 1;
        num_aa[20] = 2;
        num_aa[30] = 3;
        result = num_aa.first(ikey);
        result = num_aa.next(ikey);
        if (result == 1 && ikey == 20) begin
            $display("Test 4 PASS: integer key next");
            passed++;
        end else begin
            $display("Test 4 FAIL: integer key next, got %0d", ikey);
            failed++;
        end

        // Test 5: Full iteration count
        aa.delete();
        aa["a"] = 1;
        aa["b"] = 2;
        aa["c"] = 3;
        aa["d"] = 4;
        begin
            static int count = 0;
            result = aa.first(key);
            while (result) begin
                count++;
                result = aa.next(key);
            end
            if (count == 4) begin
                $display("Test 5 PASS: full iteration count");
                passed++;
            end else begin
                $display("Test 5 FAIL: full iteration count, got %0d", count);
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
