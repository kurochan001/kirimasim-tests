/*
:name: test_comb_systask_math
:description: Test: System math functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 20.8.1 20.8.2 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comb_systask_math.expected
*/
// Test: System math functions
module test_comb_systask_math;
    real r1, r2;
    integer i1;
    int pass_count;

    initial begin
        pass_count = 0;

        // $ceil / $floor
        r1 = $ceil(3.2);
        if (r1 == 4.0) pass_count++;
        else $error("ceil(3.2) = %f, expected 4.0", r1);

        r1 = $ceil(-1.7);
        if (r1 == -1.0) pass_count++;
        else $error("ceil(-1.7) = %f, expected -1.0", r1);

        r1 = $floor(3.7);
        if (r1 == 3.0) pass_count++;
        else $error("floor(3.7) = %f, expected 3.0", r1);

        r1 = $floor(-2.3);
        if (r1 == -3.0) pass_count++;
        else $error("floor(-2.3) = %f, expected -3.0", r1);

        // $sqrt
        r1 = $sqrt(16.0);
        if (r1 == 4.0) pass_count++;
        else $error("sqrt(16) = %f, expected 4.0", r1);

        r1 = $sqrt(2.0);
        if (r1 > 1.41 && r1 < 1.42) pass_count++;
        else $error("sqrt(2) = %f, expected ~1.414", r1);

        // $pow
        r1 = $pow(2.0, 10.0);
        if (r1 == 1024.0) pass_count++;
        else $error("pow(2,10) = %f, expected 1024.0", r1);

        // $exp / $ln / $log10
        r1 = $exp(1.0);
        if (r1 > 2.71 && r1 < 2.72) pass_count++;
        else $error("exp(1) = %f, expected ~2.718", r1);

        r1 = $ln(2.718281828);
        if (r1 > 0.999 && r1 < 1.001) pass_count++;
        else $error("ln(e) = %f, expected ~1.0", r1);

        r1 = $log10(1000.0);
        if (r1 > 2.999 && r1 < 3.001) pass_count++;
        else $error("log10(1000) = %f, expected 3.0", r1);

        // $sin / $cos / $tan / $asin / $acos / $atan / $atan2
        r1 = $sin(0.0);
        if (r1 == 0.0) pass_count++;

        r1 = $cos(0.0);
        if (r1 == 1.0) pass_count++;

        r1 = $tan(0.0);
        if (r1 == 0.0) pass_count++;

        r1 = $asin(1.0);
        if (r1 > 1.57 && r1 < 1.58) pass_count++;

        r1 = $acos(0.0);
        if (r1 > 1.57 && r1 < 1.58) pass_count++;

        r1 = $atan(1.0);
        if (r1 > 0.78 && r1 < 0.79) pass_count++;

        r1 = $atan2(1.0, 1.0);
        if (r1 > 0.78 && r1 < 0.79) pass_count++;

        // $hypot
        r1 = $hypot(3.0, 4.0);
        if (r1 == 5.0) pass_count++;

        // $sinh / $cosh / $tanh
        r1 = $sinh(0.0);
        if (r1 == 0.0) pass_count++;

        r1 = $cosh(0.0);
        if (r1 == 1.0) pass_count++;

        r1 = $tanh(0.0);
        if (r1 == 0.0) pass_count++;

        // $clog2
        i1 = $clog2(256);
        if (i1 == 8) pass_count++;
        else $error("clog2(256) = %0d, expected 8", i1);

        i1 = $clog2(255);
        if (i1 == 8) pass_count++;
        else $error("clog2(255) = %0d, expected 8", i1);

        i1 = $clog2(1);
        if (i1 == 0) pass_count++;
        else $error("clog2(1) = %0d, expected 0", i1);

        // $signed / $unsigned
        r1 = $itor(42);
        i1 = $rtoi(3.99);
        if (i1 == 3) pass_count++;

        // $countones / $countbits / $onehot / $onehot0 / $isunknown
        i1 = $countones(8'b10110101);
        if (i1 == 5) pass_count++;

        if ($onehot(8'b00000100)) pass_count++;
        if (!$onehot(8'b00000101)) pass_count++;

        if ($onehot0(8'b00000000)) pass_count++;
        if ($onehot0(8'b00000100)) pass_count++;
        if (!$onehot0(8'b00000101)) pass_count++;

        if (!$isunknown(8'b10110101)) pass_count++;

        // $bits
        i1 = $bits(r1);
        // $bits on real should return 64

        $display("pass_count = %0d", pass_count);
        if (pass_count >= 25)
            $display("PASS: test_comb_systask_math");
        else
            $display("FAIL: test_comb_systask_math (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
