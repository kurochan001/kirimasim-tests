/*
:name: test_generate_conditional_2
:description: An if generate construct choosing between two continuous assignments
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_conditional_2.expected
*/
`timescale 1ns/1ps

module test_generate_conditional;
    parameter USE_FAST = 1;
    parameter WIDTH = 8;

    logic [WIDTH-1:0] a, b, result;

    // Conditional generate
    generate
        if (USE_FAST) begin : fast_impl
            assign result = a + b;
        end else begin : slow_impl
            assign result = a - b;
        end
    endgenerate

    initial begin
        a = 10;
        b = 5;
        #1;

        if (USE_FAST) begin
            if (result != 15) $display("FAIL: fast path expected 15");
        end else begin
            if (result != 5) $display("FAIL: slow path expected 5");
        end

        $display("TEST PASSED");
        $finish;
    end
endmodule
