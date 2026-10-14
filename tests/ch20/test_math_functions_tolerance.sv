/*
:name: test_math_functions_tolerance
:description: Real math system functions compared within a tolerance
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_functions_tolerance.expected
*/
// Math system functions
module test_math_functions_tolerance;
    int pass_count = 0;
    real r1, r2, result;
    int i1;

    initial begin
        // Test $ln (natural log)
        r1 = 2.718281828;
        result = $ln(r1);
        if (result > 0.99 && result < 1.01) pass_count++;

        // Test $log10
        r1 = 100.0;
        result = $log10(r1);
        if (result > 1.99 && result < 2.01) pass_count++;

        // Test $exp
        r1 = 1.0;
        result = $exp(r1);
        if (result > 2.71 && result < 2.72) pass_count++;

        // Test $sqrt
        r1 = 16.0;
        result = $sqrt(r1);
        if (result > 3.99 && result < 4.01) pass_count++;

        // Test $pow
        r1 = 2.0;
        r2 = 3.0;
        result = $pow(r1, r2);
        if (result > 7.99 && result < 8.01) pass_count++;

        // Test $floor
        r1 = 3.7;
        result = $floor(r1);
        if (result == 3.0) pass_count++;

        // Test $ceil
        r1 = 3.2;
        result = $ceil(r1);
        if (result == 4.0) pass_count++;

        // Test $sin
        r1 = 0.0;
        result = $sin(r1);
        if (result > -0.01 && result < 0.01) pass_count++;

        // Test $cos
        r1 = 0.0;
        result = $cos(r1);
        if (result > 0.99 && result < 1.01) pass_count++;

        // Test $tan
        r1 = 0.0;
        result = $tan(r1);
        if (result > -0.01 && result < 0.01) pass_count++;

        $display("PASS: math functions (%0d/10)", pass_count);
        $finish;
    end
endmodule
