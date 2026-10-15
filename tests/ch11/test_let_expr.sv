/*
:name: test_let_expr
:description: let declarations that call other let declarations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_expr.expected
*/
// let declarations that call other let declarations (11.12)
`timescale 1ns/1ps
module test_let_expr;
    let add(a, b) = a + b;
    let mul(a, b) = a * b;
    let mac(a, b, c) = add(mul(a, b), c);
    
    int fails = 0;

    
    initial begin
        if (add(3, 4) != 7) begin fails++; $display("FAIL: add"); end
        if (mul(3, 4) != 12) begin fails++; $display("FAIL: mul"); end
        if (mac(2, 3, 4) != 10) begin fails++; $display("FAIL: mac"); end
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
