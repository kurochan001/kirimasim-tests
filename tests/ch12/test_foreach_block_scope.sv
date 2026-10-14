/*
:name: test_foreach_block_scope
:description: foreach with block-scoped arrays
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3 9.3.1 7.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_block_scope.expected
*/
// IEEE 1800-2023 §12.7.3: foreach with block-scoped arrays
// Verify foreach resolves array names correctly when shadowed by block-local variables
module test_foreach_block_scope;
    int arr[3] = '{100, 200, 300};  // Outer array
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Block-local array shadows outer array in foreach
    initial begin : test1
        static int arr[3] = '{1, 2, 3};  // Inner array (shadows outer)
        static int sum = 0;
        foreach (arr[i]) begin
            sum += arr[i];
        end
        // Should use inner arr: sum = 6
        if (sum == 6) begin
            $display("PASS: Test 1 - foreach uses block-local array (sum=%0d)", sum);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - foreach got sum=%0d, expected 6", sum);
            fail_count++;
        end
    end

    // Test 2: foreach on outer array when no shadowing
    // Each block reports at its own time step so the output order is defined (4.7).
    initial begin : test2
        static int sum = 0;
        #1;
        foreach (arr[i]) begin
            sum += arr[i];
        end
        // Should use outer arr: sum = 600
        if (sum == 600) begin
            $display("PASS: Test 2 - foreach uses outer array (sum=%0d)", sum);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - foreach got sum=%0d, expected 600", sum);
            fail_count++;
        end
    end

    // Test 3: foreach with dynamic array in block scope
    initial begin : test3
        static int darr[] = '{10, 20, 30, 40, 50};
        static int sum = 0;
        #2;
        foreach (darr[i]) begin
            sum += darr[i];
        end
        if (sum == 150) begin
            $display("PASS: Test 3 - foreach on block-local dynamic array (sum=%0d)", sum);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - foreach dynamic array got sum=%0d, expected 150", sum);
            fail_count++;
        end
    end

    // Summary
    initial begin
        #3;
        $display("\n=== foreach block scope tests: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
