/*
:name: test_system_funcs
:description: Bit vector system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 20.8.1 20.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_funcs.expected
*/
// IEEE 1800-2023 Section 20.9: Bit vector system functions
module test_system_funcs;
    logic [7:0] a;
    int result;

    initial begin
        a = 8'b10110100;

        // $countones
        result = $countones(a);
        if (result == 4)
            $display("PASS: $countones(0xB4) = 4");
        else
            $display("FAIL: $countones = %0d", result);

        // $onehot
        a = 8'b00001000;
        result = $onehot(a);
        if (result == 1)
            $display("PASS: $onehot(0x08) = 1");
        else
            $display("FAIL: $onehot = %0d", result);

        a = 8'b00001100;
        result = $onehot(a);
        if (result == 0)
            $display("PASS: $onehot(0x0C) = 0");
        else
            $display("FAIL: $onehot = %0d", result);

        // $clog2
        result = $clog2(16);
        if (result == 4)
            $display("PASS: $clog2(16) = 4");
        else
            $display("FAIL: $clog2(16) = %0d", result);

        result = $clog2(17);
        if (result == 5)
            $display("PASS: $clog2(17) = 5");
        else
            $display("FAIL: $clog2(17) = %0d", result);

        // $bits
        result = $bits(a);
        if (result == 8)
            $display("PASS: $bits = 8");
        else
            $display("FAIL: $bits = %0d", result);

        $display("TEST PASSED: system function tests completed");
        $finish;
    end
endmodule
