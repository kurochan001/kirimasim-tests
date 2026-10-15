/*
:name: test_always_comb_reads_writes
:description: always_comb with several reads and writes, including a conditional operator
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_reads_writes.expected
*/
module test_always_comb_reads_writes;
    int pass_count = 0;
    logic [7:0] in1, in2, in3;
    logic [7:0] out1, out2;
    logic sel;

    // Multiple reads and writes in always_comb
    always_comb begin
        out1 = in1 + in2;
        out2 = sel ? in1 : in3;
    end

    initial begin
        in1 = 8'd5;
        in2 = 8'd10;
        in3 = 8'd15;
        sel = 1;
        #1;
        if (out1 == 8'd15) pass_count++;
        if (out2 == 8'd5) pass_count++;

        sel = 0;
        #1;
        if (out2 == 8'd15) pass_count++;

        $display("PASS: always_comb reads and writes (%0d/3)", pass_count);
        $finish;
    end
endmodule
