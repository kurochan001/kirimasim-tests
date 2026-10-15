/*
:name: test_assoc_array_edge_cases
:description: Associative array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_edge_cases.expected
*/
// IEEE 1800-2023 §7.8: Associative array edge cases
// Tests for associative arrays

module test_assoc_array_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int assoc_int[int];
    string assoc_str[string];
    int assoc_wild[*];

    initial begin
        // Test 1: Basic insert
        test_count++;
        assoc_int[10] = 100;
        if (assoc_int[10] == 100) begin
            pass_count++;
            $display("Test 1 PASS: assoc[10] = %0d", assoc_int[10]);
        end else begin
            $display("Test 1 FAIL: Insert unexpected");
        end

        // Test 2: Multiple inserts
        test_count++;
        assoc_int[20] = 200;
        assoc_int[30] = 300;
        if (assoc_int[20] == 200 && assoc_int[30] == 300) begin
            pass_count++;
            $display("Test 2 PASS: Multi insert");
        end else begin
            $display("Test 2 FAIL: Multi unexpected");
        end

        // Test 3: Size
        test_count++;
        if (assoc_int.size() == 3) begin
            pass_count++;
            $display("Test 3 PASS: size = %0d", assoc_int.size());
        end else begin
            $display("Test 3 FAIL: size unexpected = %0d", assoc_int.size());
        end

        // Test 4: Exists
        test_count++;
        if (assoc_int.exists(10)) begin
            pass_count++;
            $display("Test 4 PASS: exists(10) = true");
        end else begin
            $display("Test 4 FAIL: exists unexpected");
        end

        // Test 5: Not exists
        test_count++;
        if (!assoc_int.exists(999)) begin
            pass_count++;
            $display("Test 5 PASS: exists(999) = false");
        end else begin
            $display("Test 5 FAIL: not exists unexpected");
        end

        // Test 6: Delete single
        test_count++;
        assoc_int.delete(20);
        if (!assoc_int.exists(20)) begin
            pass_count++;
            $display("Test 6 PASS: Deleted 20");
        end else begin
            $display("Test 6 FAIL: Delete unexpected");
        end

        // Test 7: First
        test_count++;
        begin
            int key;
            if (assoc_int.first(key)) begin
                pass_count++;
                $display("Test 7 PASS: first key = %0d", key);
            end else begin
                $display("Test 7 FAIL: first unexpected");
            end
        end

        // Test 8: Last
        test_count++;
        begin
            int key;
            if (assoc_int.last(key)) begin
                pass_count++;
                $display("Test 8 PASS: last key = %0d", key);
            end else begin
                $display("Test 8 FAIL: last unexpected");
            end
        end

        // Test 9: Next
        test_count++;
        begin
            static int key = 10;
            if (assoc_int.next(key)) begin
                pass_count++;
                $display("Test 9 PASS: next key = %0d", key);
            end else begin
                $display("Test 9 FAIL: next unexpected");
            end
        end

        // Test 10: String key
        test_count++;
        assoc_str["hello"] = "world";
        if (assoc_str["hello"] == "world") begin
            pass_count++;
            $display("Test 10 PASS: string key");
        end else begin
            $display("Test 10 FAIL: string unexpected");
        end

        // Test 11: Delete all
        test_count++;
        assoc_int.delete();
        if (assoc_int.size() == 0) begin
            pass_count++;
            $display("Test 11 PASS: delete all, size = 0");
        end else begin
            $display("Test 11 FAIL: delete all unexpected");
        end

        // Test 12: Rebuild
        test_count++;
        assoc_int[1] = 11;
        assoc_int[2] = 22;
        if (assoc_int.size() == 2) begin
            pass_count++;
            $display("Test 12 PASS: rebuild size = %0d", assoc_int.size());
        end else begin
            $display("Test 12 FAIL: rebuild unexpected");
        end

        $display("=== Assoc Array Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
