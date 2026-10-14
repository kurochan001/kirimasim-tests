/*
:name: test_bitwise
:description: Bitwise operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise.expected
*/
// IEEE 1800-2023 Section 11.4.8: Bitwise operators
module test_bitwise;
    logic [7:0] a, b, result;

    initial begin
        a = 8'hAA;  // 10101010
        b = 8'h55;  // 01010101

        // Bitwise AND
        result = a & b;
        if (result == 8'h00)
            $display("PASS: 0xAA & 0x55 = 0x00");
        else
            $display("FAIL: & = 0x%h", result);

        // Bitwise OR
        result = a | b;
        if (result == 8'hFF)
            $display("PASS: 0xAA | 0x55 = 0xFF");
        else
            $display("FAIL: | = 0x%h", result);

        // Bitwise XOR
        result = a ^ b;
        if (result == 8'hFF)
            $display("PASS: 0xAA ^ 0x55 = 0xFF");
        else
            $display("FAIL: ^ = 0x%h", result);

        // Bitwise NOT
        result = ~a;
        if (result == 8'h55)
            $display("PASS: ~0xAA = 0x55");
        else
            $display("FAIL: ~ = 0x%h", result);

        // Bitwise XNOR
        result = a ~^ b;
        if (result == 8'h00)
            $display("PASS: 0xAA ~^ 0x55 = 0x00");
        else
            $display("FAIL: ~^ = 0x%h", result);

        $display("TEST PASSED: bitwise tests completed");
        $finish;
    end
endmodule
