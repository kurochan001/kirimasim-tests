/*
:name: test_system_math
:description: Real math functions, rounding and $clog2
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_math.expected
*/
`timescale 1ns/1ps

module test_system_math;
    real r;
    int i;

    initial begin
        // Basic math
        r = $sqrt(16.0);
        if (r < 3.99 || r > 4.01) $display("FAIL: sqrt");

        r = $pow(2.0, 10.0);
        if (r < 1023.0 || r > 1025.0) $display("FAIL: pow");

        r = $exp(1.0);
        if (r < 2.71 || r > 2.72) $display("FAIL: exp");

        r = $ln(2.718281828);
        if (r < 0.99 || r > 1.01) $display("FAIL: ln");

        r = $log10(100.0);
        if (r < 1.99 || r > 2.01) $display("FAIL: log10");

        // Trigonometric
        r = $sin(0.0);
        if (!(r > 0.0 - 1e-9 && r < 0.0 + 1e-9)) $display("FAIL: sin(0)");

        r = $cos(0.0);
        if (r < 0.99 || r > 1.01) $display("FAIL: cos(0)");

        r = $tan(0.0);
        if (!(r > 0.0 - 1e-9 && r < 0.0 + 1e-9)) $display("FAIL: tan(0)");

        // Hyperbolic
        r = $sinh(0.0);
        if (!(r > 0.0 - 1e-9 && r < 0.0 + 1e-9)) $display("FAIL: sinh(0)");

        r = $cosh(0.0);
        if (r < 0.99 || r > 1.01) $display("FAIL: cosh(0)");

        // Rounding
        r = $floor(3.7);
        if (r != 3.0) $display("FAIL: floor");

        r = $ceil(3.2);
        if (r != 4.0) $display("FAIL: ceil");

        // Bit operations
        i = $clog2(8);
        if (i != 3) $display("FAIL: clog2(8)");

        i = $clog2(9);
        if (i != 4) $display("FAIL: clog2(9)");

        $display("TEST PASSED");
        $finish;
    end
endmodule
