/*
:name: test_assoc_delete_2
:description: Test: Associative array delete method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_delete_2.expected
*/
// Test: Associative array delete method
module test_assoc_delete_2;
    int aa[string];
    int num_aa[int];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Delete single entry
        aa["one"] = 1;
        aa["two"] = 2;
        aa.delete("one");
        if (aa.num() == 1 && !aa.exists("one") && aa.exists("two")) begin
            $display("Test 1 PASS: delete single entry");
            passed++;
        end else begin
            $display("Test 1 FAIL: delete single entry");
            failed++;
        end

        // Test 2: Delete all entries
        aa["three"] = 3;
        aa.delete();
        if (aa.num() == 0) begin
            $display("Test 2 PASS: delete all entries");
            passed++;
        end else begin
            $display("Test 2 FAIL: delete all entries");
            failed++;
        end

        // Test 3: Delete with integer key
        num_aa[100] = 10;
        num_aa[200] = 20;
        num_aa[300] = 30;
        num_aa.delete(200);
        if (num_aa.num() == 2 && !num_aa.exists(200)) begin
            $display("Test 3 PASS: delete integer key");
            passed++;
        end else begin
            $display("Test 3 FAIL: delete integer key");
            failed++;
        end

        // Test 4: Delete from empty (no error expected)
        aa.delete();
        aa.delete("nonexistent");  // Should not cause error
        if (aa.num() == 0) begin
            $display("Test 4 PASS: delete from empty");
            passed++;
        end else begin
            $display("Test 4 FAIL: delete from empty");
            failed++;
        end

        // Test 5: Delete last entry
        aa["only"] = 99;
        aa.delete("only");
        if (aa.num() == 0 && !aa.exists("only")) begin
            $display("Test 5 PASS: delete last entry");
            passed++;
        end else begin
            $display("Test 5 FAIL: delete last entry");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
