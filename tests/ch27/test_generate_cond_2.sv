/*
:name: test_generate_cond_2
:description: An if-else generate chain with a variable in the chosen block
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_cond_2.expected
*/
// An if-else generate chain with a variable in the chosen block
module test_generate_cond;
    parameter MODE = 1;
    
    generate
        if (MODE == 0) begin : gen_mode0
            logic [7:0] data;
            initial data = 8'h00;
        end else if (MODE == 1) begin : gen_mode1
            logic [15:0] data;
            initial data = 16'h1111;
        end else begin : gen_default
            logic [31:0] data;
            initial data = 32'hFFFF;
        end
    endgenerate
    
    initial begin
        #1;
        if (gen_mode1.data == 16'h1111)
            $display("PASS: Generate cond test");
        else
            $display("FAIL");
        $finish;
    end
endmodule
