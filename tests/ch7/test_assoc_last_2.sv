/*
:name: test_assoc_last_2
:description: Test: Associative array last method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_last_2.expected
*/
// Test: Associative array last method
module test_assoc_last_2;
    int aa[string];
    int num_aa[int];
    string key;
    int ikey;
    int result;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Last on empty array
        result = aa.last(key);
        if (result == 0) begin
            $display("Test 1 PASS: last on empty array returns 0");
            passed++;
        end else begin
            $display("Test 1 FAIL: last on empty array");
            failed++;
        end

        // Test 2: Last with single entry
        aa["apple"] = 1;
        result = aa.last(key);
        if (result == 1 && key == "apple") begin
            $display("Test 2 PASS: last with single entry");
            passed++;
        end else begin
            $display("Test 2 FAIL: last with single entry");
            failed++;
        end

        // Test 3: Last with multiple entries (string order)
        aa["banana"] = 2;
        aa["cherry"] = 3;
        result = aa.last(key);
        if (result == 1 && key == "cherry") begin
            $display("Test 3 PASS: last returns largest key");
            passed++;
        end else begin
            $display("Test 3 FAIL: last returns largest key, got %s", key);
            failed++;
        end

        // Test 4: Integer key last
        num_aa[300] = 30;
        num_aa[100] = 10;
        num_aa[200] = 20;
        result = num_aa.last(ikey);
        if (result == 1 && ikey == 300) begin
            $display("Test 4 PASS: last integer key");
            passed++;
        end else begin
            $display("Test 4 FAIL: last integer key, got %0d", ikey);
            failed++;
        end

        // Test 5: Last after deleting last entry
        num_aa.delete(300);
        result = num_aa.last(ikey);
        if (result == 1 && ikey == 200) begin
            $display("Test 5 PASS: last after delete");
            passed++;
        end else begin
            $display("Test 5 FAIL: last after delete");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
