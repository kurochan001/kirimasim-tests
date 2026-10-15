/*
:name: test_generate_expr
:description: Parameter expressions used in a range and a generate condition
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_expr.expected
*/
`timescale 1ns/1ps

module test_generate_expr;
    parameter A = 10;
    parameter B = 5;
    parameter C = A + B;
    parameter D = A * B;
    parameter E = A - B;
    parameter F = A / B;
    parameter G = A % B;

    // Conditional parameter expressions
    parameter USE_LARGE = (A > B);
    parameter SIZE = USE_LARGE ? 16 : 8;

    // Bit operations in parameters
    parameter MASK = (1 << A) - 1;
    parameter SHIFTED = B << 2;

    logic [SIZE-1:0] data;

    generate
        if (C == 15) begin : correct_sum
            assign data = {SIZE{1'b1}};
        end
    endgenerate

    initial begin
        if (C != 15) $display("FAIL: C");
        if (D != 50) $display("FAIL: D");
        if (E != 5) $display("FAIL: E");
        if (F != 2) $display("FAIL: F");
        if (G != 0) $display("FAIL: G");
        if (!USE_LARGE) $display("FAIL: USE_LARGE");
        if (SIZE != 16) $display("FAIL: SIZE");
        if (MASK != 1023) $display("FAIL: MASK");
        if (SHIFTED != 20) $display("FAIL: SHIFTED");

        #1;
        if (data != 16'hFFFF) $display("FAIL: data");

        $display("TEST PASSED");
        $finish;
    end
endmodule
