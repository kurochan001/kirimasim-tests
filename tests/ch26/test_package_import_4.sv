/*
:name: test_package_import_4
:description: Package import test
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_4.expected
*/
// Package import test
package import_pkg_a;
    localparam int CONST_A = 100;
    typedef logic [7:0] type_a;
    function int func_a();
        return 42;
    endfunction
endpackage

package import_pkg_b;
    localparam int CONST_B = 200;
    typedef logic [15:0] type_b;
    function int func_b();
        return 84;
    endfunction
endpackage

package import_pkg_c;
    localparam int CONST_C = 300;
    localparam int CONST_A = 999;  // Same name as import_pkg_a
endpackage

module test_package_import;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Wildcard import
    import import_pkg_a::*;
    type_a data_a = 8'hFF;

    // Test 2: Specific import
    import import_pkg_b::CONST_B;
    import import_pkg_b::type_b;

    // Test 3: Multiple imports from same package
    import import_pkg_b::func_b;

    // Test 4: Explicit scope override
    localparam int EXPLICIT_A = import_pkg_a::CONST_A;
    localparam int EXPLICIT_C_A = import_pkg_c::CONST_A;

    // Test 5: Nested scope access
    type_b data_b;

    initial begin
        #1;

        // Test 1: Wildcard import
        if (CONST_A == 100 && $bits(data_a) == 8) begin
            $display("PASS: Test 1 - Wildcard import (CONST_A=%0d)", CONST_A);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Wildcard import failed");
            fail_count++;
        end

        // Test 2: Specific import
        if (CONST_B == 200 && $bits(type_b) == 16) begin
            $display("PASS: Test 2 - Specific import (CONST_B=%0d)", CONST_B);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Specific import failed");
            fail_count++;
        end

        // Test 3: Function import
        if (func_a() == 42 && func_b() == 84) begin
            $display("PASS: Test 3 - Function imports (func_a=%0d, func_b=%0d)",
                     func_a(), func_b());
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Function imports failed");
            fail_count++;
        end

        // Test 4: Explicit scope differentiates same-named constants
        if (EXPLICIT_A == 100 && EXPLICIT_C_A == 999) begin
            $display("PASS: Test 4 - Explicit scope (A=%0d, C.A=%0d)",
                     EXPLICIT_A, EXPLICIT_C_A);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Explicit scope failed");
            fail_count++;
        end

        // Test 5: Type usage from specific import
        data_b = 16'hABCD;
        if (data_b == 16'hABCD) begin
            $display("PASS: Test 5 - Type from specific import");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Type import failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
