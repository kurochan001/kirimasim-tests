/*
:name: test_assoc_num
:description: Test: Associative array num method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_num.expected
*/
// Test: Associative array num method
module test_assoc_num;
    int aa[string];
    int num_aa[int];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Empty associative array
        if (aa.num() == 0) begin
            $display("Test 1 PASS: empty assoc array num");
            passed++;
        end else begin
            $display("Test 1 FAIL: empty assoc array num, got %0d", aa.num());
            failed++;
        end

        // Test 2: Single entry
        aa["one"] = 1;
        if (aa.num() == 1) begin
            $display("Test 2 PASS: single entry num");
            passed++;
        end else begin
            $display("Test 2 FAIL: single entry num");
            failed++;
        end

        // Test 3: Multiple entries
        aa["two"] = 2;
        aa["three"] = 3;
        if (aa.num() == 3) begin
            $display("Test 3 PASS: three entries num");
            passed++;
        end else begin
            $display("Test 3 FAIL: three entries num");
            failed++;
        end

        // Test 4: Integer keys
        num_aa[100] = 10;
        num_aa[200] = 20;
        num_aa[300] = 30;
        num_aa[400] = 40;
        if (num_aa.num() == 4) begin
            $display("Test 4 PASS: integer key assoc num");
            passed++;
        end else begin
            $display("Test 4 FAIL: integer key assoc num");
            failed++;
        end

        // Test 5: Num after delete
        aa.delete("one");
        if (aa.num() == 2) begin
            $display("Test 5 PASS: num after delete");
            passed++;
        end else begin
            $display("Test 5 FAIL: num after delete");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
