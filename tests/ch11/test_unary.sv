/*
:name: test_unary
:description: Unary operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unary.expected
*/
// IEEE 1800-2023 Section 11.4.2: Unary operators
module test_unary;
    int a, result;
    logic [7:0] b;

    initial begin
        // Unary plus
        a = 5;
        result = +a;
        if (result == 5)
            $display("PASS: +5 = 5");
        else
            $display("FAIL: + = %0d", result);

        // Unary minus
        result = -a;
        if (result == -5)
            $display("PASS: -5 = -5");
        else
            $display("FAIL: - = %0d", result);

        // Pre-increment
        a = 10;
        result = ++a;
        if (result == 11 && a == 11)
            $display("PASS: ++10 = 11");
        else
            $display("FAIL: ++a = %0d, a = %0d", result, a);

        // Pre-decrement
        result = --a;
        if (result == 10 && a == 10)
            $display("PASS: --11 = 10");
        else
            $display("FAIL: --a = %0d, a = %0d", result, a);

        // Post-increment
        a = 5;
        result = a++;
        if (result == 5 && a == 6)
            $display("PASS: 5++ = 5, a = 6");
        else
            $display("FAIL: a++ = %0d, a = %0d", result, a);

        // Post-decrement
        result = a--;
        if (result == 6 && a == 5)
            $display("PASS: 6-- = 6, a = 5");
        else
            $display("FAIL: a-- = %0d, a = %0d", result, a);

        $display("TEST PASSED: unary tests completed");
        $finish;
    end
endmodule
