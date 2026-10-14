/*
:name: test_system_functions
:description: $clog2, $bits, $signed, $unsigned, $ceil, $floor and $sqrt (IEEE 1800-2023 Sections 20.6.2, 20.8 and 11.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.6.2 20.8.2 11.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_functions.expected
*/
// IEEE 1800-2023 Section 20

module test_system_functions;
    int val;
    real r;
    logic [31:0] lv;

    initial begin
        val = $clog2(16);
        if (val == 4)
            $display("PASS: $clog2(16) = %0d", val);
        else
            $display("FAIL: $clog2(16) got %0d", val);

        val = $clog2(17);
        if (val == 5)
            $display("PASS: $clog2(17) = %0d", val);
        else
            $display("FAIL: $clog2(17) got %0d", val);

        val = $bits(lv);
        if (val == 32)
            $display("PASS: $bits(logic[31:0]) = %0d", val);
        else
            $display("FAIL: $bits got %0d", val);

        lv = 32'hFFFFFFFF;
        val = $signed(lv);
        if (val == -1)
            $display("PASS: $signed = %0d", val);
        else
            $display("FAIL: $signed got %0d", val);

        val = -1;
        lv = $unsigned(val);
        if (lv == 32'hFFFFFFFF)
            $display("PASS: $unsigned = %h", lv);
        else
            $display("FAIL: $unsigned got %h", lv);

        r = $ceil(3.2);
        if (r == 4.0)
            $display("PASS: $ceil(3.2) = %f", r);
        else
            $display("FAIL: $ceil got %f", r);

        r = $floor(3.8);
        if (r == 3.0)
            $display("PASS: $floor(3.8) = %f", r);
        else
            $display("FAIL: $floor got %f", r);

        r = $sqrt(16.0);
        if (r == 4.0)
            $display("PASS: $sqrt(16) = %f", r);
        else
            $display("FAIL: $sqrt got %f", r);

        $display("TEST PASSED: system functions completed");
        $finish;
    end
endmodule
