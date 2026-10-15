/*
:name: test_scope_resolution
:description: Scope Resolution Tests
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 23.7.1 21.2.1.5 9.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_resolution.expected
*/
// IEEE 1800-2023 Sections 26.3 and 23.7.1 - Scope Resolution Tests
// Tests: packages, scope operator ::, hierarchical names

package pkg1;
    parameter int PKG_PARAM = 100;
    typedef int pkg_int_t;

    function int pkg_func(int x);
        return x * 2;
    endfunction
endpackage

package pkg2;
    parameter int PKG_PARAM = 200;
endpackage

module test_scope_resolution;
    import pkg1::*;

    int pass_count = 0;
    int fail_count = 0;

    int local_var;
    pkg_int_t pkg_typed_var;

    initial begin
        $display("=== IEEE 1800-2023 Scope Resolution Tests ===");

        // Test 1: Package parameter access
        $display("Test 1: Package parameter");
        if (pkg1::PKG_PARAM == 100) begin
            $display("Test 1 PASS: pkg1::PKG_PARAM=%0d", pkg1::PKG_PARAM);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Different package same name
        $display("Test 2: Different package same parameter name");
        if (pkg2::PKG_PARAM == 200) begin
            $display("Test 2 PASS: pkg2::PKG_PARAM=%0d", pkg2::PKG_PARAM);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Package function call
        $display("Test 3: Package function");
        if (pkg1::pkg_func(5) == 10) begin
            $display("Test 3 PASS: pkg_func(5)=%0d", pkg1::pkg_func(5));
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Imported type
        $display("Test 4: Imported typedef");
        pkg_typed_var = 42;
        if (pkg_typed_var == 42) begin
            $display("Test 4 PASS: pkg_typed_var=%0d", pkg_typed_var);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Local variable
        $display("Test 5: Local variable");
        local_var = 123;
        if (local_var == 123) begin
            $display("Test 5 PASS: local_var=%0d", local_var);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Imported function via wildcard
        $display("Test 6: Imported function");
        if (pkg_func(10) == 20) begin
            $display("Test 6 PASS: pkg_func(10)=%0d", pkg_func(10));
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Module path display
        $display("Test 7: Module path");
        $display("  Module: %m");
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Package constant expressions
        $display("Test 8: Package constant in expression");
        local_var = pkg1::PKG_PARAM + pkg2::PKG_PARAM;
        if (local_var == 300) begin
            $display("Test 8 PASS: sum=%0d", local_var);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
