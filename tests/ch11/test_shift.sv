/*
:name: test_shift
:description: Shift operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift.expected
*/
// IEEE 1800-2023 Section 11.4.10: Shift operators
module test_shift;
    logic [7:0] a, result;
    logic signed [7:0] s;
    int shift_amt;

    initial begin
        a = 8'h0F;

        // Left shift
        result = a << 2;
        if (result == 8'h3C)
            $display("PASS: 0x0F << 2 = 0x3C");
        else
            $display("FAIL: << = 0x%h", result);

        // Right shift
        a = 8'hF0;
        result = a >> 4;
        if (result == 8'h0F)
            $display("PASS: 0xF0 >> 4 = 0x0F");
        else
            $display("FAIL: >> = 0x%h", result);

        // Arithmetic right shift (signed)
        s = -8;  // 0xF8
        s = s >>> 2;
        if (s == -2)
            $display("PASS: -8 >>> 2 = -2");
        else
            $display("FAIL: >>> = %0d", s);

        // Variable shift amount
        a = 8'h01;
        shift_amt = 5;
        result = a << shift_amt;
        if (result == 8'h20)
            $display("PASS: 0x01 << 5 = 0x20");
        else
            $display("FAIL: variable shift = 0x%h", result);

        $display("TEST PASSED: shift tests completed");
        $finish;
    end
endmodule
