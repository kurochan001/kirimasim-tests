/*
:name: test_binary_expr
:description: Arithmetic and bitwise expressions in always_comb, with 8-bit wrap-around
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_binary_expr.expected
*/
module test_binary_expr;
    int pass_count = 0;
    logic [7:0] a, b, c, d;
    logic [7:0] r1, r2, r3, r4;

    always_comb begin
        r1 = a + b;
        r2 = a - b;
        r3 = a & c;
        r4 = (a | b) ^ (c & d);
    end

    initial begin
        a = 8'hFF;
        b = 8'h0F;
        c = 8'hF0;
        d = 8'hAA;
        #1;

        if (r1 == 8'h0E) pass_count++;  // FF + 0F = 10E (truncated to 0E)
        if (r2 == 8'hF0) pass_count++;  // FF - 0F = F0
        if (r3 == 8'hF0) pass_count++;  // FF & F0 = F0
        if (r4 == 8'h5F) pass_count++;  // (FF | 0F) ^ (F0 & AA) = FF ^ A0 = 5F

        $display("PASS: binary expr (%0d/4)", pass_count);
        $finish;
    end
endmodule
