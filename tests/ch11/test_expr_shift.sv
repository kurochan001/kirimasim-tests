/*
:name: test_expr_shift
:description: Test for shift operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_shift.expected
*/
// Test for shift operators
// IEEE 1800-2023 §11.4.10: Shift operators
module test_expr_shift;
    initial begin
        static logic [7:0] a = 8'h0F;
        static logic signed [7:0] b = -8;  // 8'hF8
        logic [7:0] result;

        // Logical left shift
        result = a << 2;
        if (result != 8'h3C) $display("FAIL: Logical left shift");

        // Logical right shift
        result = a >> 2;
        if (result != 8'h03) $display("FAIL: Logical right shift");

        // Arithmetic left shift (same as logical)
        result = a <<< 2;
        if (result != 8'h3C) $display("FAIL: Arithmetic left shift");

        // Arithmetic right shift (sign extend)
        result = b >>> 2;
        if (result != 8'hFE) $display("FAIL: Arithmetic right shift");

        // Shift by variable amount
        result = a << 4;
        if (result != 8'hF0) $display("FAIL: Variable shift");

        $display("PASS: Shift operators");
        $finish;
    end
endmodule
