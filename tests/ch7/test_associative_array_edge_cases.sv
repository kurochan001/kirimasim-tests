/*
:name: test_associative_array_edge_cases
:description: Associative array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.4 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_array_edge_cases.expected
*/
// IEEE 1800-2023 §7.8: Associative array edge cases
// Tests for associative array operations

module test_associative_array_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int aa[string];
    int aa_int[int];
    string keys[$];

    initial begin
        // Test 1: Add element to empty array
        test_count++;
        aa["first"] = 100;
        if (aa["first"] == 100) begin
            pass_count++;
            $display("Test 1 PASS: Add to empty array");
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: Num elements
        test_count++;
        if (aa.num() == 1) begin
            pass_count++;
            $display("Test 2 PASS: num() = %0d", aa.num());
        end else begin
            $display("Test 2 FAIL: num = %0d", aa.num());
        end

        // Test 3: Exists check (existing)
        test_count++;
        if (aa.exists("first")) begin
            pass_count++;
            $display("Test 3 PASS: exists(first) = true");
        end else begin
            $display("Test 3 FAIL");
        end

        // Test 4: Exists check (non-existing)
        test_count++;
        if (!aa.exists("nonexistent")) begin
            pass_count++;
            $display("Test 4 PASS: exists(nonexistent) = false");
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Multiple elements
        test_count++;
        aa["second"] = 200;
        aa["third"] = 300;
        if (aa.num() == 3) begin
            pass_count++;
            $display("Test 5 PASS: num after adds = %0d", aa.num());
        end else begin
            $display("Test 5 FAIL: num = %0d", aa.num());
        end

        // Test 6: Delete specific element
        test_count++;
        aa.delete("second");
        if (aa.num() == 2 && !aa.exists("second")) begin
            pass_count++;
            $display("Test 6 PASS: delete(second) worked");
        end else begin
            $display("Test 6 FAIL");
        end

        // Test 7: First key
        test_count++;
        begin
            string k;
            if (aa.first(k)) begin
                pass_count++;
                $display("Test 7 PASS: first key = %s", k);
            end else begin
                $display("Test 7 FAIL");
            end
        end

        // Test 8: Last key
        test_count++;
        begin
            string k;
            if (aa.last(k)) begin
                pass_count++;
                $display("Test 8 PASS: last key = %s", k);
            end else begin
                $display("Test 8 FAIL");
            end
        end

        // Test 9: Next key
        test_count++;
        begin
            static string k = "first";
            if (aa.next(k)) begin
                pass_count++;
                $display("Test 9 PASS: next after first = %s", k);
            end else begin
                $display("Test 9 FAIL");
            end
        end

        // Test 10: Delete all
        test_count++;
        aa.delete();
        if (aa.num() == 0) begin
            pass_count++;
            $display("Test 10 PASS: delete all, num = %0d", aa.num());
        end else begin
            $display("Test 10 FAIL: num = %0d", aa.num());
        end

        // Test 11: Int key array
        test_count++;
        aa_int[100] = 1;
        aa_int[200] = 2;
        aa_int[50] = 3;
        if (aa_int.num() == 3) begin
            pass_count++;
            $display("Test 11 PASS: int key array num = %0d", aa_int.num());
        end else begin
            $display("Test 11 FAIL");
        end

        // Test 12: Int key first (smallest)
        test_count++;
        begin
            int k;
            // Integral keys are ordered by value (7.8.4).
            if (aa_int.first(k) && k == 50) begin
                pass_count++;
                $display("Test 12 PASS: int first key = %0d", k);
            end else begin
                $display("Test 12 FAIL: int first key = %0d", k);
            end
        end

        // Test 13: Overwrite value
        test_count++;
        aa_int[100] = 999;
        if (aa_int[100] == 999) begin
            pass_count++;
            $display("Test 13 PASS: overwrite value = %0d", aa_int[100]);
        end else begin
            $display("Test 13 FAIL");
        end

        // Test 14: Negative int key
        test_count++;
        aa_int[-50] = 42;
        if (aa_int[-50] == 42) begin
            pass_count++;
            $display("Test 14 PASS: negative key works");
        end else begin
            $display("Test 14 FAIL");
        end

        // Test 15: Zero int key
        test_count++;
        aa_int[0] = 0;
        if (aa_int.exists(0) && aa_int[0] == 0) begin
            pass_count++;
            $display("Test 15 PASS: zero key works");
        end else begin
            $display("Test 15 FAIL");
        end

        // Test 16: Prev key
        test_count++;
        begin
            static int k = 200;
            // The keys are -50, 0, 50, 100 and 200 here.
            if (aa_int.prev(k) && k == 100) begin
                pass_count++;
                $display("Test 16 PASS: prev before 200 = %0d", k);
            end else begin
                $display("Test 16 FAIL: prev before 200 = %0d", k);
            end
        end

        // Test 17: Empty string key
        test_count++;
        aa[""] = 777;
        if (aa[""] == 777) begin
            pass_count++;
            $display("Test 17 PASS: empty string key works");
        end else begin
            $display("Test 17 FAIL");
        end

        // Test 18: Multiple elements with explicit keys
        test_count++;
        aa.delete();
        aa["key1"] = 100;
        aa["key2"] = 200;
        aa["key3"] = 300;
        aa["key4"] = 400;
        aa["key5"] = 500;
        if (aa.num() == 5) begin
            pass_count++;
            $display("Test 18 PASS: 5 elements added, num = %0d", aa.num());
        end else begin
            $display("Test 18 FAIL: num = %0d", aa.num());
        end

        // Test 19: Access by key
        test_count++;
        if (aa["key3"] == 300) begin
            pass_count++;
            $display("Test 19 PASS: aa[key3] = %0d", aa["key3"]);
        end else begin
            $display("Test 19 FAIL: value = %0d", aa["key3"]);
        end

        // Test 20: Size after delete
        test_count++;
        aa.delete("key1");
        aa.delete("key5");
        if (aa.num() == 3) begin
            pass_count++;
            $display("Test 20 PASS: num after deletes = %0d", aa.num());
        end else begin
            $display("Test 20 FAIL: num = %0d", aa.num());
        end

        $display("=== Associative Array Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
