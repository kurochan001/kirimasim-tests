/*
:name: test_increment_decrement
:description: Increment/Decrement Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_increment_decrement.expected
*/
// IEEE 1800-2023 Section 11.4.2 - Increment/Decrement Operators Tests
module test_increment_decrement;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a;

        $display("=== IEEE 1800-2023 Increment/Decrement Tests ===");

        // Test 1: Simple increment
        $display("Test 1: Simple ++");
        a = 5; a++;
        if (a == 6) begin $display("Test 1 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 1 FAIL: a=%0d", a); fail_count++; end

        // Test 2: Simple decrement
        $display("Test 2: Simple --");
        a = 5; a--;
        if (a == 4) begin $display("Test 2 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 2 FAIL: a=%0d", a); fail_count++; end

        // Test 3: Multiple increments
        $display("Test 3: Multiple ++");
        a = 0; a++; a++; a++;
        if (a == 3) begin $display("Test 3 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 3 FAIL: a=%0d", a); fail_count++; end

        // Test 4: Multiple decrements
        $display("Test 4: Multiple --");
        a = 10; a--; a--; a--;
        if (a == 7) begin $display("Test 4 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 4 FAIL: a=%0d", a); fail_count++; end

        // Test 5: Decrement to negative
        $display("Test 5: Decrement to negative");
        a = 0; a--;
        if (a == -1) begin $display("Test 5 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 5 FAIL: a=%0d", a); fail_count++; end

        // Test 6: In loop
        $display("Test 6: In for loop");
        a = 0;
        for (int i = 0; i < 5; i++) a++;
        if (a == 5) begin $display("Test 6 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 6 FAIL: a=%0d", a); fail_count++; end

        // Test 7: Countdown
        $display("Test 7: Countdown");
        a = 10;
        while (a > 5) a--;
        if (a == 5) begin $display("Test 7 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 7 FAIL: a=%0d", a); fail_count++; end

        // Test 8: Alternate
        $display("Test 8: Alternate");
        a = 0; a++; a--; a++; a++;
        if (a == 2) begin $display("Test 8 PASS: a=%0d", a); pass_count++; end
        else begin $display("Test 8 FAIL: a=%0d", a); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
