/*
:name: test_reduction
:description: Reduction operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction.expected
*/
// IEEE 1800-2023 Section 11.4.9: Reduction operators
module test_reduction;
    logic [7:0] a;
    logic result;

    initial begin
        // Reduction AND
        a = 8'hFF;
        result = &a;
        if (result == 1)
            $display("PASS: &0xFF = 1");
        else
            $display("FAIL: &0xFF = %b", result);

        a = 8'hFE;
        result = &a;
        if (result == 0)
            $display("PASS: &0xFE = 0");
        else
            $display("FAIL: &0xFE = %b", result);

        // Reduction OR
        a = 8'h00;
        result = |a;
        if (result == 0)
            $display("PASS: |0x00 = 0");
        else
            $display("FAIL: |0x00 = %b", result);

        a = 8'h01;
        result = |a;
        if (result == 1)
            $display("PASS: |0x01 = 1");
        else
            $display("FAIL: |0x01 = %b", result);

        // Reduction XOR
        a = 8'hAA;  // 10101010 - 4 ones, even parity
        result = ^a;
        if (result == 0)
            $display("PASS: ^0xAA = 0 (even parity)");
        else
            $display("FAIL: ^0xAA = %b", result);

        a = 8'hAB;  // 10101011 - 5 ones, odd parity
        result = ^a;
        if (result == 1)
            $display("PASS: ^0xAB = 1 (odd parity)");
        else
            $display("FAIL: ^0xAB = %b", result);

        $display("TEST PASSED: reduction tests completed");
        $finish;
    end
endmodule
