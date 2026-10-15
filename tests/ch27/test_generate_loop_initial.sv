/*
:name: test_generate_loop_initial
:description: initial blocks in loop generate blocks, and nested if generate constructs
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop_initial.expected
*/
`timescale 1ns/1ps

module test_generate_loop_initial;
    parameter WIDTH = 8;
    parameter DEPTH = 4;
    parameter ENABLE = 1;

    logic [WIDTH-1:0] data[DEPTH];

    // if generate construct with a constant condition
    generate
        if (ENABLE) begin : enabled
            logic [WIDTH-1:0] buffer;
            assign buffer = data[0] ^ data[1];
        end
    endgenerate

    // Loop generate construct with an initial block in each block
    generate
        genvar i;
        for (i = 0; i < DEPTH; i++) begin : init_loop
            initial data[i] = i * 10;
        end
    endgenerate

    // Nested if generate constructs
    generate
        if (WIDTH > 4) begin : wide
            if (DEPTH > 2) begin : deep
                logic [WIDTH-1:0] extra;
                assign extra = data[0] + data[1] + data[2] + data[3];
            end
        end
    endgenerate

    initial begin
        #1;
        if (data[0] != 0) $display("FAIL: data[0]");
        if (data[1] != 10) $display("FAIL: data[1]");
        if (data[2] != 20) $display("FAIL: data[2]");
        if (data[3] != 30) $display("FAIL: data[3]");

        $display("TEST PASSED");
        $finish;
    end
endmodule
