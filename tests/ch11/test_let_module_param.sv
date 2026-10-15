/*
:name: test_let_module_param
:description: let declarations that use a module parameter
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 6.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_module_param.expected
*/
`timescale 1ns/1ps

module test_let_module_param;
    parameter WIDTH = 8;

    // Let with parameter-dependent operations
    let mask(x) = x & ((1 << WIDTH) - 1);
    let clamp(x, min_v, max_v) = (x < min_v) ? min_v : ((x > max_v) ? max_v : x);
    let abs_val(x) = (x < 0) ? -x : x;

    int fails = 0;


    initial begin
        int result;

        // Test mask with parameter
        result = mask(32'hFFFFFFFF);
        if (result != 8'hFF) begin fails++; $display("FAIL: mask"); end

        // Test clamp
        result = clamp(150, 0, 100);
        if (result != 100) begin fails++; $display("FAIL: clamp high"); end

        result = clamp(-10, 0, 100);
        if (result != 0) begin fails++; $display("FAIL: clamp low"); end

        result = clamp(50, 0, 100);
        if (result != 50) begin fails++; $display("FAIL: clamp mid"); end

        // Test abs
        result = abs_val(-42);
        if (result != 42) begin fails++; $display("FAIL: abs negative"); end

        result = abs_val(42);
        if (result != 42) begin fails++; $display("FAIL: abs positive"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
