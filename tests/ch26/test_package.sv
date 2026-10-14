/*
:name: test_package
:description: Test for package usage
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package.expected
*/
// Test for package usage
// IEEE 1800-2023 §26

package my_pkg;
    typedef int my_int_t;
    localparam int PKG_CONST = 100;
    
    function int pkg_func(int x);
        return x + PKG_CONST;
    endfunction
endpackage

module test_package;
    import my_pkg::*;
    
    my_int_t val;
    int result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Package typedef
        test_count++;
        val = 42;
        if (val == 42) begin
            $display("Test 1: Package typedef PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Package constant
        test_count++;
        result = PKG_CONST;
        if (result == 100) begin
            $display("Test 2: Package constant PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Package function
        test_count++;
        result = pkg_func(50);
        if (result == 150) begin
            $display("Test 3: Package function PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Use typedef variable
        test_count++;
        val = val + 8;
        if (val == 50) begin
            $display("Test 4: Use typedef variable PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
