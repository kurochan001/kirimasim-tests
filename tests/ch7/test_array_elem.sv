/*
:name: test_array_elem
:description: Array Element Access Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 10.9.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_elem.expected
*/
// IEEE 1800-2023 Section 7.4 - Array Element Access Tests
module test_array_elem;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        static int arr[5] = '{10, 20, 30, 40, 50};
        static logic [7:0] bytes[4] = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
        int idx;

        $display("=== IEEE 1800-2023 Array Element Access Tests ===");

        $display("Test 1: First element");
        if (arr[0] == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", arr[0]); fail_count++; end

        $display("Test 2: Last element");
        if (arr[4] == 50) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", arr[4]); fail_count++; end

        $display("Test 3: Variable index");
        idx = 2;
        if (arr[idx] == 30) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", arr[idx]); fail_count++; end

        $display("Test 4: Modify element");
        arr[1] = 99;
        if (arr[1] == 99) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", arr[1]); fail_count++; end

        $display("Test 5: Logic array");
        if (bytes[0] == 8'hAA && bytes[3] == 8'hDD) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Expression index");
        if (arr[1+1] == 30) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", arr[1+1]); fail_count++; end

        $display("Test 7: Modify via index");
        idx = 3;
        arr[idx] = 77;
        if (arr[3] == 77) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", arr[3]); fail_count++; end

        $display("Test 8: Sum elements");
        if (arr[0] + arr[4] == 60) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", arr[0] + arr[4]); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
