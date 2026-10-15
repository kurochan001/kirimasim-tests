/*
:name: test_part_select_variable_base
:description: Constant part-selects and an indexed part-select with a variable base
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_part_select_variable_base.expected
*/
module test_part_select_variable_base;
    int pass_count = 0;
    logic [15:0] data;
    logic [7:0] high_byte, low_byte;
    logic [3:0] nibble;
    logic [1:0] sel;

    always_comb begin
        high_byte = data[15:8];
        low_byte = data[7:0];
        nibble = data[sel*4 +: 4];
    end

    initial begin
        data = 16'hABCD;
        sel = 2'd0;
        #1;
        if (high_byte == 8'hAB) pass_count++;
        if (low_byte == 8'hCD) pass_count++;
        if (nibble == 4'hD) pass_count++;

        sel = 2'd2;
        #1;
        if (nibble == 4'hB) pass_count++;

        $display("PASS: select expr (%0d/4)", pass_count);
        $finish;
    end
endmodule
