/*
:name: test_let_expressions
:description: let declarations with one to three arguments, nested let calls and operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_expressions.expected
*/
`timescale 1ns/1ps

module test_let_expressions;
    // Various let patterns
    let simple(x) = x + 1;
    let binary(a, b) = a + b;
    let ternary(a, b, c) = a ? b : c;
    let nested(x) = simple(simple(x));

    // Let with expressions
    let shift_add(x, n) = (x << n) + 1;
    let mask_and(x, m) = x & m;

    // Complex let
    let complex(a, b, c) = (a * b) + (b * c) - (a * c);

    int fails = 0;


    initial begin
        int result;

        // Test simple
        result = simple(5);
        if (result != 6) begin fails++; $display("FAIL: simple"); end

        // Test binary
        result = binary(3, 4);
        if (result != 7) begin fails++; $display("FAIL: binary"); end

        // Test ternary
        result = ternary(1, 10, 20);
        if (result != 10) begin fails++; $display("FAIL: ternary true"); end

        result = ternary(0, 10, 20);
        if (result != 20) begin fails++; $display("FAIL: ternary false"); end

        // Test nested
        result = nested(5);
        if (result != 7) begin fails++; $display("FAIL: nested"); end

        // Test shift_add
        result = shift_add(4, 2);
        if (result != 17) begin fails++; $display("FAIL: shift_add"); end

        // Test mask_and
        result = mask_and(32'hFF, 32'h0F);
        if (result != 32'h0F) begin fails++; $display("FAIL: mask_and"); end

        // Test complex
        result = complex(2, 3, 4);
        if (result != 6 + 12 - 8) begin fails++; $display("FAIL: complex"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
