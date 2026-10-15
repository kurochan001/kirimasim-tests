/*
:name: test_package_advanced
:description: Advanced Package Tests
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_advanced.expected
*/
// IEEE 1800-2023 Section 26 - Advanced Package Tests
// Tests: Package imports, exports, nested packages

package pkg_types;
    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;

    parameter int PKG_VERSION = 1;
endpackage

package pkg_funcs;
    import pkg_types::*;

    function automatic byte_t add_bytes(byte_t a, byte_t b);
        return a + b;
    endfunction

    function automatic word_t concat_bytes(byte_t hi, byte_t lo);
        return {hi, lo};
    endfunction
endpackage

package pkg_constants;
    parameter int MAX_SIZE = 256;
    parameter int MIN_SIZE = 1;
endpackage

module test_package_advanced;
    import pkg_types::*;
    import pkg_funcs::*;
    import pkg_constants::*;

    int pass_count = 0;
    int fail_count = 0;

    byte_t b1, b2, b3;
    word_t w1;
    dword_t d1;

    initial begin
        $display("=== IEEE 1800-2023 Advanced Package Tests ===");

        // Test 1: Package typedef usage
        $display("Test 1: Package typedef usage");
        b1 = 8'hAB;
        if (b1 == 8'hAB) begin
            $display("Test 1 PASS: byte_t b1=%h", b1);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", b1);
            fail_count++;
        end

        // Test 2: Package function call
        $display("Test 2: Package function call");
        b1 = 8'h10;
        b2 = 8'h20;
        b3 = add_bytes(b1, b2);
        if (b3 == 8'h30) begin
            $display("Test 2 PASS: add_bytes(10,20)=%h", b3);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", b3);
            fail_count++;
        end

        // Test 3: Another package function
        $display("Test 3: Concat function");
        b1 = 8'hAA;
        b2 = 8'hBB;
        w1 = concat_bytes(b1, b2);
        if (w1 == 16'hAABB) begin
            $display("Test 3 PASS: concat_bytes(AA,BB)=%h", w1);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", w1);
            fail_count++;
        end

        // Test 4: Package parameter
        $display("Test 4: Package parameter");
        if (PKG_VERSION == 1) begin
            $display("Test 4 PASS: PKG_VERSION=%0d", PKG_VERSION);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %0d", PKG_VERSION);
            fail_count++;
        end

        // Test 5: Package constant MAX_SIZE
        $display("Test 5: Package constant MAX_SIZE");
        if (MAX_SIZE == 256) begin
            $display("Test 5 PASS: MAX_SIZE=%0d", MAX_SIZE);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %0d", MAX_SIZE);
            fail_count++;
        end

        // Test 6: Package constant MIN_SIZE
        $display("Test 6: Package constant MIN_SIZE");
        if (MIN_SIZE == 1) begin
            $display("Test 6 PASS: MIN_SIZE=%0d", MIN_SIZE);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %0d", MIN_SIZE);
            fail_count++;
        end

        // Test 7: Dword typedef
        $display("Test 7: Dword typedef");
        d1 = 32'hDEADBEEF;
        if (d1 == 32'hDEADBEEF) begin
            $display("Test 7 PASS: dword_t d1=%h", d1);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", d1);
            fail_count++;
        end

        // Test 8: Combined function result
        $display("Test 8: Combined function result");
        b1 = 8'hF0;
        b2 = 8'h0F;
        b3 = add_bytes(b1, b2);
        if (b3 == 8'hFF) begin
            $display("Test 8 PASS: add_bytes(F0,0F)=%h", b3);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", b3);
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
