/*
:name: test_exists_method
:description: exists() method of associative arrays with int and string keys
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exists_method.expected
*/
// IEEE 1800-2023: 7.9.3 - exists() method of associative arrays
// Test: exists() method - only valid for associative arrays

module test_exists_method;
    initial begin
        static int passed = 0;
        static int failed = 0;

        // ===== Test 1: Associative array with int key =====
        begin
            int assoc_int[int];
            assoc_int[5] = 100;
            assoc_int[10] = 200;
            assoc_int[15] = 300;

            // Should exist
            if (assoc_int.exists(5)) begin
                $display("PASS: assoc_int.exists(5) = 1");
                passed++;
            end else begin
                $display("FAIL: assoc_int.exists(5) should return 1");
                failed++;
            end

            if (assoc_int.exists(10)) begin
                $display("PASS: assoc_int.exists(10) = 1");
                passed++;
            end else begin
                $display("FAIL: assoc_int.exists(10) should return 1");
                failed++;
            end

            // Should not exist
            if (!assoc_int.exists(0)) begin
                $display("PASS: assoc_int.exists(0) = 0");
                passed++;
            end else begin
                $display("FAIL: assoc_int.exists(0) should return 0");
                failed++;
            end

            if (!assoc_int.exists(20)) begin
                $display("PASS: assoc_int.exists(20) = 0");
                passed++;
            end else begin
                $display("FAIL: assoc_int.exists(20) should return 0");
                failed++;
            end
        end

        // ===== Test 2: Associative array with string key =====
        begin
            int assoc_str[string];
            assoc_str["apple"] = 1;
            assoc_str["banana"] = 2;
            assoc_str["cherry"] = 3;

            // Should exist
            if (assoc_str.exists("apple")) begin
                $display("PASS: assoc_str.exists(\"apple\") = 1");
                passed++;
            end else begin
                $display("FAIL: assoc_str.exists(\"apple\") should return 1");
                failed++;
            end

            // Should not exist
            if (!assoc_str.exists("orange")) begin
                $display("PASS: assoc_str.exists(\"orange\") = 0");
                passed++;
            end else begin
                $display("FAIL: assoc_str.exists(\"orange\") should return 0");
                failed++;
            end
        end

        // ===== Test 3: Empty associative array =====
        begin
            int empty_assoc[int];

            if (!empty_assoc.exists(0)) begin
                $display("PASS: empty_assoc.exists(0) = 0");
                passed++;
            end else begin
                $display("FAIL: empty_assoc.exists(0) should return 0");
                failed++;
            end
        end

        // ===== Test 4: After delete =====
        begin
            int assoc_del[int];
            assoc_del[1] = 100;
            assoc_del[2] = 200;

            // Should exist before delete
            if (assoc_del.exists(1)) begin
                $display("PASS: assoc_del.exists(1) before delete = 1");
                passed++;
            end else begin
                $display("FAIL: assoc_del.exists(1) before delete should return 1");
                failed++;
            end

            // Delete key 1
            assoc_del.delete(1);

            // Should not exist after delete
            if (!assoc_del.exists(1)) begin
                $display("PASS: assoc_del.exists(1) after delete = 0");
                passed++;
            end else begin
                $display("FAIL: assoc_del.exists(1) after delete should return 0");
                failed++;
            end

            // Key 2 should still exist
            if (assoc_del.exists(2)) begin
                $display("PASS: assoc_del.exists(2) after deleting key 1 = 1");
                passed++;
            end else begin
                $display("FAIL: assoc_del.exists(2) after deleting key 1 should return 1");
                failed++;
            end
        end

        // ===== Test 5: Negative key in int-keyed associative array =====
        begin
            int assoc_neg[int];
            assoc_neg[-5] = 50;
            assoc_neg[-10] = 100;

            if (assoc_neg.exists(-5)) begin
                $display("PASS: assoc_neg.exists(-5) = 1");
                passed++;
            end else begin
                $display("FAIL: assoc_neg.exists(-5) should return 1");
                failed++;
            end

            if (!assoc_neg.exists(5)) begin
                $display("PASS: assoc_neg.exists(5) = 0");
                passed++;
            end else begin
                $display("FAIL: assoc_neg.exists(5) should return 0");
                failed++;
            end
        end

        // ===== Summary =====
        $display("========================================");
        $display("exists() Method Test Summary:");
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        $display("  Total:  %0d", passed + failed);
        $display("========================================");

        if (failed == 0) begin
            $display("ALL TESTS PASSED");
            $finish(0);
        end else begin
            $display("SOME TESTS FAILED");
            $finish(1);
        end
    end
endmodule
