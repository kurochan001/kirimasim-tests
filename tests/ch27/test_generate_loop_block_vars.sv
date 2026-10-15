/*
:name: test_generate_loop_block_vars
:description: Variables declared in loop generate blocks, read by hierarchical names
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop_block_vars.expected
*/
`timescale 1ns/1ps

module test_generate_loop_block_vars;
    parameter N = 4;

    // Generate loop
    generate
        genvar i;
        for (i = 0; i < N; i++) begin : gen_loop
            logic [7:0] data;
            initial data = i * 10;
        end
    endgenerate

    initial begin
        #1;
        // Access generated instances
        if (gen_loop[0].data != 0) $display("FAIL: gen_loop[0]");
        if (gen_loop[1].data != 10) $display("FAIL: gen_loop[1]");
        if (gen_loop[2].data != 20) $display("FAIL: gen_loop[2]");
        if (gen_loop[3].data != 30) $display("FAIL: gen_loop[3]");

        $display("TEST PASSED");
        $finish;
    end
endmodule
