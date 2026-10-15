/*
:name: test_assoc_array_edge_cases_2
:description: Test: Associative array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_edge_cases_2.expected
*/
// Test: Associative array edge cases
// IEEE 1800-2023 Section 7.8 Associative arrays
// Tests corner cases: associative array operations

`timescale 1ns/1ps

module test_assoc_array_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int aa[string];
        int aa_int[int];

        $display("TEST: Associative array edge cases");

        // Test 1: Empty size
        begin
            if (aa.size() == 0) begin
                $display("  [PASS] Empty size");
                passed++;
            end else begin
                $display("  [FAIL] Empty: %0d", aa.size());
                failed++;
            end
        end

        // Test 2: String key insert
        begin
            aa["one"] = 1;
            if (aa["one"] == 1) begin
                $display("  [PASS] String key insert");
                passed++;
            end else begin
                $display("  [FAIL] Insert: %0d", aa["one"]);
                failed++;
            end
        end

        // Test 3: Multiple keys
        begin
            aa["two"] = 2;
            aa["three"] = 3;
            if (aa.size() == 3) begin
                $display("  [PASS] Multiple keys");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", aa.size());
                failed++;
            end
        end

        // Test 4: Key update
        begin
            aa["one"] = 10;
            if (aa["one"] == 10) begin
                $display("  [PASS] Key update");
                passed++;
            end else begin
                $display("  [FAIL] Update: %0d", aa["one"]);
                failed++;
            end
        end

        // Test 5: Exists check
        begin
            if (aa.exists("two")) begin
                $display("  [PASS] Exists check");
                passed++;
            end else begin
                $display("  [FAIL] Exists");
                failed++;
            end
        end

        // Test 6: Delete key
        begin
            aa.delete("three");
            if (aa.size() == 2) begin
                $display("  [PASS] Delete key");
                passed++;
            end else begin
                $display("  [FAIL] Delete: %0d", aa.size());
                failed++;
            end
        end

        // Test 7: Int key insert
        begin
            aa_int[100] = 1000;
            aa_int[200] = 2000;
            if (aa_int[100] == 1000 && aa_int[200] == 2000) begin
                $display("  [PASS] Int key insert");
                passed++;
            end else begin
                $display("  [FAIL] IntKey");
                failed++;
            end
        end

        // Test 8: Int key size
        begin
            if (aa_int.size() == 2) begin
                $display("  [PASS] Int key size");
                passed++;
            end else begin
                $display("  [FAIL] IntSize: %0d", aa_int.size());
                failed++;
            end
        end

        // Test 9: Delete all
        begin
            aa.delete();
            if (aa.size() == 0) begin
                $display("  [PASS] Delete all");
                passed++;
            end else begin
                $display("  [FAIL] DelAll: %0d", aa.size());
                failed++;
            end
        end

        // Test 10: Rebuild
        begin
            aa["new"] = 999;
            if (aa["new"] == 999 && aa.size() == 1) begin
                $display("  [PASS] Rebuild");
                passed++;
            end else begin
                $display("  [FAIL] Rebuild");
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
