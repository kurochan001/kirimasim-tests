/*
:name: test_let_nested
:description: let declarations composed several levels deep
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_nested.expected
*/
`timescale 1ns/1ps

module test_let_nested;
    // Multi-level nested lets
    let inc(x) = x + 1;
    let dec(x) = x - 1;
    let double(x) = x * 2;
    let half(x) = x / 2;

    // Composition of let functions
    let inc_double(x) = double(inc(x));
    let half_dec(x) = dec(half(x));
    let chain(x) = double(inc(dec(double(x))));

    int fails = 0;


    initial begin
        int val;

        // Test nested compositions
        val = inc_double(5); // (5+1)*2 = 12
        if (val != 12) begin fails++; $display("FAIL: inc_double expected 12, got %0d", val); end

        val = half_dec(10); // (10/2)-1 = 4
        if (val != 4) begin fails++; $display("FAIL: half_dec expected 4, got %0d", val); end

        val = chain(3); // double(inc(dec(double(3)))) = double(inc(dec(6))) = double(inc(5)) = double(6) = 12
        if (val != 12) begin fails++; $display("FAIL: chain expected 12, got %0d", val); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
