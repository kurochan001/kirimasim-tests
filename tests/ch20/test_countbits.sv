/*
:name: test_countbits
:description: Bit counting functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countbits.expected
*/
// IEEE 1800-2023 Section 20.9: Bit counting functions
module test_countbits;
    logic [7:0] val;
    int result;

    initial begin
        // $countones
        val = 8'b1010_1010;
        result = $countones(val);
        if (result == 4)
            $display("PASS: $countones");
        else
            $display("FAIL: countones = %0d", result);

        val = 8'b1111_1111;
        result = $countones(val);
        if (result == 8)
            $display("PASS: $countones all");
        else
            $display("FAIL: countones all = %0d", result);

        val = 8'b0000_0000;
        result = $countones(val);
        if (result == 0)
            $display("PASS: $countones zero");
        else
            $display("FAIL: countones zero = %0d", result);

        // $countbits
        val = 8'b1010_1010;
        result = $countbits(val, 1'b1);
        if (result == 4)
            $display("PASS: $countbits");
        else
            $display("FAIL: countbits = %0d", result);

        $display("TEST PASSED: countbits tests completed");
        $finish;
    end
endmodule
