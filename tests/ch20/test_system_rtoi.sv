/*
:name: test_system_rtoi
:description: $rtoi - real to integer conversion
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_rtoi.expected
*/
// $rtoi - real to integer conversion
module test_rtoi;
    real r1, r2, r3, r4, r5;
    integer i1, i2, i3, i4, i5;

    initial begin
        // Test 1: Positive real truncation
        r1 = 3.7;
        i1 = $rtoi(r1);
        if (i1 == 3)
            $display("PASS: $rtoi(3.7) = %0d", i1);
        else
            $display("FAIL: $rtoi(3.7) = %0d, expected 3", i1);

        // Test 2: Negative real truncation
        r2 = -2.9;
        i2 = $rtoi(r2);
        if (i2 == -2)
            $display("PASS: $rtoi(-2.9) = %0d", i2);
        else
            $display("FAIL: $rtoi(-2.9) = %0d, expected -2", i2);

        // Test 3: Exact integer value
        r3 = 100.0;
        i3 = $rtoi(r3);
        if (i3 == 100)
            $display("PASS: $rtoi(100.0) = %0d", i3);
        else
            $display("FAIL: $rtoi(100.0) = %0d, expected 100", i3);

        // Test 4: Small positive fraction
        r4 = 0.999;
        i4 = $rtoi(r4);
        if (i4 == 0)
            $display("PASS: $rtoi(0.999) = %0d", i4);
        else
            $display("FAIL: $rtoi(0.999) = %0d, expected 0", i4);

        // Test 5: Large value
        r5 = 123456.789;
        i5 = $rtoi(r5);
        if (i5 == 123456)
            $display("PASS: $rtoi(123456.789) = %0d", i5);
        else
            $display("FAIL: $rtoi(123456.789) = %0d, expected 123456", i5);

        $finish;
    end
endmodule
