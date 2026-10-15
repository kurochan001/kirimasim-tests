/*
:name: test_let_basic
:description: let declarations and a let that calls other let declarations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_basic.expected
*/
`timescale 1ns/1ps

module test_let_basic;
    // Basic let declaration
    let add(a, b) = a + b;
    let mul(a, b) = a * b;
    let sub(a, b) = a - b;

    // Nested let usage
    let mac(a, b, c) = add(mul(a, b), c);

    int fails = 0;


    initial begin
        int x, y, z;

        // Test basic let functions
        x = add(3, 4);
        if (x != 7) begin fails++; $display("FAIL: add"); end

        y = mul(5, 6);
        if (y != 30) begin fails++; $display("FAIL: mul"); end

        z = sub(10, 3);
        if (z != 7) begin fails++; $display("FAIL: sub"); end

        // Test nested let
        x = mac(2, 3, 4); // 2*3 + 4 = 10
        if (x != 10) begin fails++; $display("FAIL: mac"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
