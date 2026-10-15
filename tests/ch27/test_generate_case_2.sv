/*
:name: test_generate_case_2
:description: A case generate construct choosing a continuous assignment
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_case_2.expected
*/
`timescale 1ns/1ps

module test_generate_case_block;
    parameter MODE = 2;

    logic [7:0] input_val;
    logic [7:0] output_val;

    // Generate case
    generate
        case (MODE)
            0: assign output_val = input_val;
            1: assign output_val = ~input_val;
            2: assign output_val = input_val + 1;
            default: assign output_val = 0;
        endcase
    endgenerate

    initial begin
        input_val = 8'h10;
        #1;

        case (MODE)
            0: if (output_val != 8'h10) $display("FAIL: mode 0");
            1: if (output_val != 8'hEF) $display("FAIL: mode 1");
            2: if (output_val != 8'h11) $display("FAIL: mode 2");
        endcase

        $display("TEST PASSED");
        $finish;
    end
endmodule
