/*
:name: test_package_basic_2
:description: Package (§26)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_basic_2.expected
*/
// IEEE 1800-2023 Package (§26)
// Tests basic package functionality

package my_pkg;
    parameter int PKG_CONST = 100;

    typedef logic [7:0] byte_t;
    typedef logic [31:0] word_t;

    function automatic int add(int a, int b);
        return a + b;
    endfunction

    function automatic int multiply(int a, int b);
        return a * b;
    endfunction
endpackage

module test_package_basic;
    import my_pkg::*;

    initial begin
        byte_t b;
        word_t w;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Package parameter
        if (PKG_CONST == 100) begin
            $display("PASS: PKG_CONST = %0d", PKG_CONST);
            pass_count++;
        end else begin
            $display("FAIL: PKG_CONST wrong");
            fail_count++;
        end

        // Test 2: Package typedef
        b = 8'hAB;
        w = 32'h12345678;
        if (b == 8'hAB && w == 32'h12345678) begin
            $display("PASS: Package typedefs work");
            pass_count++;
        end else begin
            $display("FAIL: Package typedefs failed");
            fail_count++;
        end

        // Test 3: Package function
        result = add(10, 20);
        if (result == 30) begin
            $display("PASS: add(10, 20) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: add(10, 20) = %0d, expected 30", result);
            fail_count++;
        end

        result = multiply(5, 6);
        if (result == 30) begin
            $display("PASS: multiply(5, 6) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: multiply(5, 6) = %0d, expected 30", result);
            fail_count++;
        end

        $display("");
        $display("=== Package Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
