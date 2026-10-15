/*
:name: test_assoc_exists_2
:description: Test: Associative array exists method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_exists_2.expected
*/
// Test: Associative array exists method
module test_assoc_exists_2;
    int aa[string];
    int num_aa[int];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Exists on empty array
        if (!aa.exists("key")) begin
            $display("Test 1 PASS: exists on empty array");
            passed++;
        end else begin
            $display("Test 1 FAIL: exists on empty array");
            failed++;
        end

        // Test 2: Exists after adding entry
        aa["hello"] = 100;
        if (aa.exists("hello")) begin
            $display("Test 2 PASS: exists after add");
            passed++;
        end else begin
            $display("Test 2 FAIL: exists after add");
            failed++;
        end

        // Test 3: Not exists for different key
        if (!aa.exists("world")) begin
            $display("Test 3 PASS: not exists for different key");
            passed++;
        end else begin
            $display("Test 3 FAIL: not exists for different key");
            failed++;
        end

        // Test 4: Integer key exists
        num_aa[42] = 999;
        num_aa[100] = 888;
        if (num_aa.exists(42) && num_aa.exists(100) && !num_aa.exists(50)) begin
            $display("Test 4 PASS: integer key exists");
            passed++;
        end else begin
            $display("Test 4 FAIL: integer key exists");
            failed++;
        end

        // Test 5: Exists after delete
        aa["temp"] = 50;
        aa.delete("temp");
        if (!aa.exists("temp") && aa.exists("hello")) begin
            $display("Test 5 PASS: exists after delete");
            passed++;
        end else begin
            $display("Test 5 FAIL: exists after delete");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
