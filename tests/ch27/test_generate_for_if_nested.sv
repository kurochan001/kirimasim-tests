/*
:name: test_generate_for_if_nested
:description: Loop, if and nested loop generate constructs
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_for_if_nested.expected
*/
`timescale 1ns/1ps

module test_generate_for_if_nested;
    parameter N = 4;

    logic [N-1:0] data_in;
    logic [N-1:0] data_out;

    // Generate for loop
    generate
        genvar i;
        for (i = 0; i < N; i++) begin : gen_inv
            assign data_out[i] = ~data_in[i];
        end
    endgenerate

    // Generate if
    generate
        if (N > 2) begin : large_n
            logic extra_sig;
            assign extra_sig = |data_in;
        end
    endgenerate

    // Nested generate
    generate
        genvar j, k;
        for (j = 0; j < 2; j++) begin : outer
            for (k = 0; k < 2; k++) begin : inner
                localparam IDX = j * 2 + k;
            end
        end
    endgenerate

    initial begin
        data_in = 4'b1010;
        #1;

        if (data_out != 4'b0101)
            $display("FAIL: inversion");

        data_in = 4'b1111;
        #1;

        if (data_out != 4'b0000)
            $display("FAIL: all ones");

        $display("TEST PASSED");
        $finish;
    end
endmodule
