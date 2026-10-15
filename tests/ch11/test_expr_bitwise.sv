/*
:name: test_expr_bitwise
:description: Test for bitwise operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_bitwise.expected
*/
// Test for bitwise operators
// IEEE 1800-2023 §11.4.8: Bitwise operators
module test_expr_bitwise;
    initial begin
        static logic [7:0] a = 8'hAA;  // 10101010
        static logic [7:0] b = 8'hF0;  // 11110000
        logic [7:0] result;

        // Bitwise AND
        result = a & b;
        if (result != 8'hA0) $display("FAIL: Bitwise AND %h", result);

        // Bitwise OR
        result = a | b;
        if (result != 8'hFA) $display("FAIL: Bitwise OR %h", result);

        // Bitwise XOR
        result = a ^ b;
        if (result != 8'h5A) $display("FAIL: Bitwise XOR %h", result);

        // Bitwise XNOR
        result = a ~^ b;
        if (result != 8'hA5) $display("FAIL: Bitwise XNOR %h", result);

        // Bitwise NOT
        result = ~a;
        if (result != 8'h55) $display("FAIL: Bitwise NOT %h", result);

        // Combined operations
        result = (a & b) | (~a & ~b);
        if (result != 8'hA5) $display("FAIL: Combined bitwise %h", result);

        $display("PASS: Bitwise operators");
        $finish;
    end
endmodule
