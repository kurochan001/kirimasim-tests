/*
:name: test_function_args
:description: Function arguments: default values and ref arguments
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 13.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_args.expected
*/
`timescale 1ns/1ps
module test_function_args;
    function automatic int add(int a, int b);
        return a + b;
    endfunction

    function automatic int with_default(int a, int b = 10);
        return a + b;
    endfunction

    task automatic modify_ref(ref int val);
        val = val * 2;
    endtask

    int x, y;

    int fails = 0;


    initial begin
        x = add(3, 4);
        if (x != 7) begin fails++; $display("FAIL: add"); end

        x = with_default(5);
        if (x != 15) begin fails++; $display("FAIL: default arg"); end

        x = with_default(5, 20);
        if (x != 25) begin fails++; $display("FAIL: override default"); end

        y = 10;
        modify_ref(y);
        if (y != 20) begin fails++; $display("FAIL: ref arg"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
