/*
:name: test_package_basic_3
:description: Basic package test
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_basic_3.expected
*/
// Basic package test
package basic_pkg;
    // Package constants
    localparam int PKG_CONST = 42;
    localparam string PKG_NAME = "basic_pkg";

    // Package variable
    int pkg_counter = 0;

    // Package type
    typedef logic [7:0] byte_t;
endpackage

package another_pkg;
    localparam int VALUE = 100;
    typedef logic [15:0] word_t;
endpackage

package empty_pkg;
    // Empty package
endpackage

module test_package_basic_3;
    import basic_pkg::*;
    import another_pkg::VALUE;

    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Access package constant
    localparam int LOCAL_CONST = PKG_CONST;

    // Test 2: Use package type
    byte_t data1 = 8'hAB;

    // Test 3: Access package from another package
    localparam int OTHER_VALUE = VALUE;

    // Test 4: Explicit package scope
    localparam int EXPLICIT_CONST = basic_pkg::PKG_CONST;

    // Test 5: Package variable
    initial begin
        #1;

        // Test 1: Package constant accessible
        if (LOCAL_CONST == 42) begin
            $display("PASS: Test 1 - Package constant accessible (%0d)", LOCAL_CONST);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Package constant incorrect");
            fail_count++;
        end

        // Test 2: Package type usable
        if (data1 == 8'hAB && $bits(data1) == 8) begin
            $display("PASS: Test 2 - Package type usable (data=%h, bits=%0d)", data1, $bits(data1));
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Package type failed");
            fail_count++;
        end

        // Test 3: Another package import
        if (OTHER_VALUE == 100) begin
            $display("PASS: Test 3 - Another package constant (%0d)", OTHER_VALUE);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Another package import failed");
            fail_count++;
        end

        // Test 4: Explicit package scope
        if (EXPLICIT_CONST == 42) begin
            $display("PASS: Test 4 - Explicit scope access (%0d)", EXPLICIT_CONST);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Explicit scope failed");
            fail_count++;
        end

        // Test 5: Package variable modification
        basic_pkg::pkg_counter = 10;
        if (basic_pkg::pkg_counter == 10) begin
            $display("PASS: Test 5 - Package variable modification");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Package variable failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
