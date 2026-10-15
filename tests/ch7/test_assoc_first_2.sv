/*
:name: test_assoc_first_2
:description: Test: Associative array first method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_first_2.expected
*/
// Test: Associative array first method
module test_assoc_first_2;
    int aa[string];
    int num_aa[int];
    string key;
    int ikey;
    int result;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: First on empty array
        result = aa.first(key);
        if (result == 0) begin
            $display("Test 1 PASS: first on empty array returns 0");
            passed++;
        end else begin
            $display("Test 1 FAIL: first on empty array");
            failed++;
        end

        // Test 2: First with single entry
        aa["apple"] = 1;
        result = aa.first(key);
        if (result == 1 && key == "apple") begin
            $display("Test 2 PASS: first with single entry");
            passed++;
        end else begin
            $display("Test 2 FAIL: first with single entry, key=%s", key);
            failed++;
        end

        // Test 3: First with multiple entries (string order)
        aa["banana"] = 2;
        aa["cherry"] = 3;
        result = aa.first(key);
        if (result == 1 && key == "apple") begin
            $display("Test 3 PASS: first returns smallest key");
            passed++;
        end else begin
            $display("Test 3 FAIL: first returns smallest key, got %s", key);
            failed++;
        end

        // Test 4: Integer key first
        num_aa[300] = 30;
        num_aa[100] = 10;
        num_aa[200] = 20;
        result = num_aa.first(ikey);
        if (result == 1 && ikey == 100) begin
            $display("Test 4 PASS: first integer key");
            passed++;
        end else begin
            $display("Test 4 FAIL: first integer key, got %0d", ikey);
            failed++;
        end

        // Test 5: First after deleting first entry
        num_aa.delete(100);
        result = num_aa.first(ikey);
        if (result == 1 && ikey == 200) begin
            $display("Test 5 PASS: first after delete");
            passed++;
        end else begin
            $display("Test 5 FAIL: first after delete");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
