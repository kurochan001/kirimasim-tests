/*
:name: test_dyn_array_edge_cases
:description: Test: Dynamic array edge cases
:tags: dyn_array
:type: simulation
:lrm: 1800-2023 7.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_edge_cases.expected
*/
// Test: Dynamic array edge cases
// IEEE 1800-2023 Section 7.5 Dynamic arrays
// Tests corner cases: dynamic array operations

`timescale 1ns/1ps

module test_dyn_array_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int da[];

        $display("TEST: Dynamic array edge cases");

        // Test 1: Empty size
        begin
            if (da.size() == 0) begin
                $display("  [PASS] Empty size");
                passed++;
            end else begin
                $display("  [FAIL] Empty: %0d", da.size());
                failed++;
            end
        end

        // Test 2: New allocation
        begin
            da = new[5];
            if (da.size() == 5) begin
                $display("  [PASS] New allocation");
                passed++;
            end else begin
                $display("  [FAIL] New: %0d", da.size());
                failed++;
            end
        end

        // Test 3: Element init
        begin
            da[0] = 10;
            da[1] = 20;
            da[2] = 30;
            if (da[0] == 10 && da[1] == 20 && da[2] == 30) begin
                $display("  [PASS] Element init");
                passed++;
            end else begin
                $display("  [FAIL] Init");
                failed++;
            end
        end

        // Test 4: Element modify
        begin
            da[0] = 100;
            if (da[0] == 100) begin
                $display("  [PASS] Element modify");
                passed++;
            end else begin
                $display("  [FAIL] Modify: %0d", da[0]);
                failed++;
            end
        end

        // Test 5: Resize larger
        begin
            da = new[8](da);
            if (da.size() == 8 && da[0] == 100) begin
                $display("  [PASS] Resize larger");
                passed++;
            end else begin
                $display("  [FAIL] ResizeLarger: size=%0d val=%0d", da.size(), da[0]);
                failed++;
            end
        end

        // Test 6: New elements are zero
        begin
            if (da[7] == 0) begin
                $display("  [PASS] New elements are zero");
                passed++;
            end else begin
                $display("  [FAIL] NewZero: %0d", da[7]);
                failed++;
            end
        end

        // Test 7: Element sum
        begin
            static int sum = 0;
            for (int i = 0; i < 3; i++) begin
                sum = sum + da[i];
            end
            if (sum == 150) begin
                $display("  [PASS] Element sum");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", sum);
                failed++;
            end
        end

        // Test 8: Resize smaller
        begin
            da = new[3](da);
            if (da.size() == 3) begin
                $display("  [PASS] Resize smaller");
                passed++;
            end else begin
                $display("  [FAIL] ResizeSmaller: %0d", da.size());
                failed++;
            end
        end

        // Test 9: Delete all
        begin
            da.delete();
            if (da.size() == 0) begin
                $display("  [PASS] Delete all");
                passed++;
            end else begin
                $display("  [FAIL] Delete: %0d", da.size());
                failed++;
            end
        end

        // Test 10: Rebuild
        begin
            da = new[2];
            da[0] = 1;
            da[1] = 2;
            if (da[0] + da[1] == 3) begin
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
