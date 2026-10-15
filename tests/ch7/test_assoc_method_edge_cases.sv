/*
:name: test_assoc_method_edge_cases
:description: Associative array method edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_method_edge_cases.expected
*/
// IEEE 1800-2023 §7.8: Associative array method edge cases
// Tests for associative array methods

module test_assoc_method_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int aa[string];
    string keys[$];
    int vals[$];

    initial begin
        // Test 1: Empty num
        test_count++;
        if (aa.num() == 0) begin
            pass_count++;
            $display("Test 1 PASS: Empty num = %0d", aa.num());
        end else begin
            $display("Test 1 FAIL: Empty unexpected = %0d", aa.num());
        end

        // Test 2: Add entries
        test_count++;
        aa["one"] = 1;
        aa["two"] = 2;
        aa["three"] = 3;
        if (aa.num() == 3) begin
            pass_count++;
            $display("Test 2 PASS: Added num = %0d", aa.num());
        end else begin
            $display("Test 2 FAIL: Add unexpected = %0d", aa.num());
        end

        // Test 3: Access value
        test_count++;
        if (aa["two"] == 2) begin
            pass_count++;
            $display("Test 3 PASS: Access 'two' = %0d", aa["two"]);
        end else begin
            $display("Test 3 FAIL: Access unexpected");
        end

        // Test 4: Exists method
        test_count++;
        if (aa.exists("one")) begin
            pass_count++;
            $display("Test 4 PASS: Exists 'one'");
        end else begin
            $display("Test 4 FAIL: Exists unexpected");
        end

        // Test 5: Not exists
        test_count++;
        if (!aa.exists("four")) begin
            pass_count++;
            $display("Test 5 PASS: Not exists 'four'");
        end else begin
            $display("Test 5 FAIL: NotExist unexpected");
        end

        // Test 6: Delete entry
        test_count++;
        aa.delete("two");
        if (aa.num() == 2 && !aa.exists("two")) begin
            pass_count++;
            $display("Test 6 PASS: Deleted 'two'");
        end else begin
            $display("Test 6 FAIL: Delete unexpected");
        end

        // Test 7: First key
        test_count++;
        begin
            string k;
            if (aa.first(k)) begin
                pass_count++;
                $display("Test 7 PASS: First key = %s", k);
            end else begin
                $display("Test 7 FAIL: First unexpected");
            end
        end

        // Test 8: Last key
        test_count++;
        begin
            string k;
            if (aa.last(k)) begin
                pass_count++;
                $display("Test 8 PASS: Last key = %s", k);
            end else begin
                $display("Test 8 FAIL: Last unexpected");
            end
        end

        // Test 9: Update value
        test_count++;
        aa["one"] = 100;
        if (aa["one"] == 100) begin
            pass_count++;
            $display("Test 9 PASS: Updated 'one' = %0d", aa["one"]);
        end else begin
            $display("Test 9 FAIL: Update unexpected");
        end

        // Test 10: Delete all
        test_count++;
        aa.delete();
        if (aa.num() == 0) begin
            pass_count++;
            $display("Test 10 PASS: Delete all num = %0d", aa.num());
        end else begin
            $display("Test 10 FAIL: DelAll unexpected = %0d", aa.num());
        end

        $display("=== Assoc Method Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
