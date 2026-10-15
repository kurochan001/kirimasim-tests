/*
:name: test_array_access
:description: An unpacked array read with a variable index in always_comb
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_access.expected
*/
module test_array_access;
    int pass_count = 0;
    logic [7:0] arr [0:3];
    logic [1:0] idx;
    logic [7:0] out;

    always_comb begin
        out = arr[idx];
    end

    initial begin
        arr[0] = 8'h10;
        arr[1] = 8'h20;
        arr[2] = 8'h30;
        arr[3] = 8'h40;

        idx = 2'd0;
        #1;
        if (out == 8'h10) pass_count++;

        idx = 2'd2;
        #1;
        if (out == 8'h30) pass_count++;

        idx = 2'd3;
        #1;
        if (out == 8'h40) pass_count++;

        $display("PASS: array access (%0d/3)", pass_count);
        $finish;
    end
endmodule
