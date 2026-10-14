/*
:name: test_shortint_byte
:description: Shortint and Byte Types Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortint_byte.expected
*/
// IEEE 1800-2023 Section 6.4 - Shortint and Byte Types Tests
module test_shortint_byte;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        byte b1, b2;
        shortint s1, s2;
        int i;

        $display("=== IEEE 1800-2023 Shortint/Byte Tests ===");

        // Test 1: Byte assignment
        $display("Test 1: Byte assignment");
        b1 = 100;
        if (b1 == 100) begin $display("Test 1 PASS: b1=%0d", b1); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", b1); fail_count++; end

        // Test 2: Byte negative
        $display("Test 2: Byte negative");
        b1 = -50;
        if (b1 == -50) begin $display("Test 2 PASS: b1=%0d", b1); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", b1); fail_count++; end

        // Test 3: Byte overflow
        $display("Test 3: Byte overflow");
        b1 = 127;
        b2 = b1 + 1;
        if (b2 == -128) begin $display("Test 3 PASS: 127+1=%0d", b2); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", b2); fail_count++; end

        // Test 4: Shortint assignment
        $display("Test 4: Shortint assignment");
        s1 = 30000;
        if (s1 == 30000) begin $display("Test 4 PASS: s1=%0d", s1); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", s1); fail_count++; end

        // Test 5: Shortint negative
        $display("Test 5: Shortint negative");
        s1 = -10000;
        if (s1 == -10000) begin $display("Test 5 PASS: s1=%0d", s1); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", s1); fail_count++; end

        // Test 6: Byte arithmetic
        $display("Test 6: Byte arithmetic");
        b1 = 50;
        b2 = 25;
        i = b1 + b2;
        if (i == 75) begin $display("Test 6 PASS: 50+25=%0d", i); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", i); fail_count++; end

        // Test 7: Shortint arithmetic
        $display("Test 7: Shortint arithmetic");
        s1 = 1000;
        s2 = 500;
        i = s1 * s2;
        if (i == 500000) begin $display("Test 7 PASS: 1000*500=%0d", i); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", i); fail_count++; end

        // Test 8: Byte to int promotion
        $display("Test 8: Byte to int");
        b1 = -10;
        i = b1;
        if (i == -10) begin $display("Test 8 PASS: int(byte -10)=%0d", i); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", i); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
