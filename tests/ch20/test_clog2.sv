/*
:name: test_clog2
:description: Math functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 20.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2.expected
*/
// IEEE 1800-2023 Section 20.9: Math functions
module test_clog2;
    int result;

    initial begin
        // $clog2
        result = $clog2(1);
        if (result == 0)
            $display("PASS: clog2(1) = 0");
        else
            $display("FAIL: clog2(1) = %0d", result);

        result = $clog2(2);
        if (result == 1)
            $display("PASS: clog2(2) = 1");
        else
            $display("FAIL: clog2(2) = %0d", result);

        result = $clog2(8);
        if (result == 3)
            $display("PASS: clog2(8) = 3");
        else
            $display("FAIL: clog2(8) = %0d", result);

        result = $clog2(9);
        if (result == 4)
            $display("PASS: clog2(9) = 4");
        else
            $display("FAIL: clog2(9) = %0d", result);

        result = $clog2(256);
        if (result == 8)
            $display("PASS: clog2(256) = 8");
        else
            $display("FAIL: clog2(256) = %0d", result);

        $display("TEST PASSED: clog2 tests completed");
        $finish;
    end
endmodule
