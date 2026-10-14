/*
:name: test_sys_math
:description: Test for math system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sys_math.expected
*/
// Test for math system functions
// IEEE 1800-2023 §20.8: Math functions
module test_sys_math;
    initial begin
        real r;
        int i;

        // $clog2
        i = $clog2(8);
        if (i != 3) $display("FAIL: clog2(8)");

        i = $clog2(9);
        if (i != 4) $display("FAIL: clog2(9)");

        // $ln
        r = $ln(2.718281828);
        if (r < 0.99 || r > 1.01) $display("FAIL: ln(e)");

        // $log10
        r = $log10(100.0);
        if (r < 1.99 || r > 2.01) $display("FAIL: log10(100)");

        // $exp
        r = $exp(1.0);
        if (r < 2.71 || r > 2.72) $display("FAIL: exp(1)");

        // $sqrt
        r = $sqrt(4.0);
        if (r < 1.99 || r > 2.01) $display("FAIL: sqrt(4)");

        // $pow
        r = $pow(2.0, 3.0);
        if (r < 7.99 || r > 8.01) $display("FAIL: pow(2,3)");

        // $floor/$ceil
        r = $floor(3.7);
        if (r != 3.0) $display("FAIL: floor");

        r = $ceil(3.2);
        if (r != 4.0) $display("FAIL: ceil");

        $display("PASS: Math functions");
        $finish;
    end
endmodule
