/*
:name: test_compound_assign
:description: Compound Assignment Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compound_assign.expected
*/
// IEEE 1800-2023 Section 10.4.1 - Compound Assignment Operators Tests
module test_compound_assign;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a;

        $display("=== IEEE 1800-2023 Compound Assignment Tests ===");

        // Test 1: +=
        $display("Test 1: += operator");
        a = 10; a += 5;
        if (a == 15) begin $display("Test 1 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 1 FAIL: a=%0d", a); fail_count++; end

        // Test 2: Simple subtraction
        $display("Test 2: Simple subtraction");
        a = 10;
        a = a - 3;
        if (a == 7) begin $display("Test 2 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 2 FAIL: a=%0d", a); fail_count++; end

        // Test 3: Multiplication
        $display("Test 3: Multiplication");
        a = 6;
        a = a * 7;
        if (a == 42) begin $display("Test 3 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 3 FAIL: a=%0d", a); fail_count++; end

        // Test 4: Simple division
        $display("Test 4: Simple division");
        a = 100;
        a = a / 4;
        if (a == 25) begin $display("Test 4 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 4 FAIL: a=%0d", a); fail_count++; end

        // Test 5: Simple modulo
        $display("Test 5: Simple modulo");
        a = 17;
        a = a % 5;
        if (a == 2) begin $display("Test 5 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 5 FAIL: a=%0d", a); fail_count++; end

        // Test 6: Bitwise AND
        $display("Test 6: Bitwise AND");
        a = 255;
        a = a & 15;
        if (a == 15) begin $display("Test 6 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 6 FAIL: a=%0d", a); fail_count++; end

        // Test 7: |=
        $display("Test 7: |= operator");
        a = 240;
        a |= 15;
        if (a == 255) begin $display("Test 7 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 7 FAIL: a=%0d", a); fail_count++; end

        // Test 8: Left shift
        $display("Test 8: Left shift");
        a = 1;
        a = a << 4;
        if (a == 16) begin $display("Test 8 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 8 FAIL: a=%0d", a); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
