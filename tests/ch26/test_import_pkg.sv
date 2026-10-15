/*
:name: test_import_pkg
:description: Package Import Tests
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_import_pkg.expected
*/
// IEEE 1800-2023 Section 26 - Package Import Tests
package my_pkg;
    int pkg_val = 100;
    int pkg_arr[3] = '{1, 2, 3};

    function int add(int a, int b);
        return a + b;
    endfunction

    function int mult(int a, int b);
        return a * b;
    endfunction
endpackage

module test_import_pkg;
    import my_pkg::*;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Package Import Tests ===");

        $display("Test 1: Package val");
        if (pkg_val == 100) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", pkg_val); fail_count++; end

        $display("Test 2: Package arr");
        if (pkg_arr[0] == 1 && pkg_arr[2] == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Package func");
        result = add(5, 3);
        if (result == 8) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Mult func");
        result = mult(4, 5);
        if (result == 20) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Chain funcs");
        result = add(mult(2, 3), 4);
        if (result == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Arr element");
        result = pkg_arr[1];
        if (result == 2) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Val + func");
        result = pkg_val + add(1, 2);
        if (result == 103) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Arr sum");
        result = pkg_arr[0] + pkg_arr[1] + pkg_arr[2];
        if (result == 6) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
