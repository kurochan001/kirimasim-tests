/*
:name: test_gen_nested_call
:description: Generate block function calling another generate function
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 13.4 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gen_nested_call.expected
*/
// Generate block function calling another generate function
module test_gen_nested_call;
    int pass_count = 0;

    parameter N = 3;
    logic [15:0] data_in[N];
    logic [15:0] data_out[N];

    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : pipe
            localparam int STAGE_ID = gi;
            localparam int GAIN = gi + 1;

            function automatic logic [15:0] amplify(logic [15:0] val);
                return val * GAIN;
            endfunction

            function automatic logic [15:0] offset(logic [15:0] val);
                return val + STAGE_ID;
            endfunction

            // Continuous assign using both functions
            assign data_out[gi] = offset(amplify(data_in[gi]));
        end
    endgenerate

    initial begin
        #1;

        // T1: Test pipeline with input 10
        for (int i = 0; i < N; i++) data_in[i] = 16'd10;
        #1;
        // pipe[0]: amplify(10)*1=10, offset(10)+0=10
        // pipe[1]: amplify(10)*2=20, offset(20)+1=21
        // pipe[2]: amplify(10)*3=30, offset(30)+2=32
        if (data_out[0] == 10 && data_out[1] == 21 && data_out[2] == 32) begin
            $display("T1: PASS - pipeline: %0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2]);
            pass_count++;
        end else
            $display("T1: FAIL - %0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2]);

        // T2: Test with input 0
        for (int i = 0; i < N; i++) data_in[i] = 16'd0;
        #1;
        // pipe[0]: 0*1+0=0, pipe[1]: 0*2+1=1, pipe[2]: 0*3+2=2
        if (data_out[0] == 0 && data_out[1] == 1 && data_out[2] == 2) begin
            $display("T2: PASS - zero input: %0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2]);
            pass_count++;
        end else
            $display("T2: FAIL - %0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2]);

        // T3: Hierarchical localparam access
        if (pipe[0].GAIN == 1 && pipe[1].GAIN == 2 && pipe[2].GAIN == 3) begin
            $display("T3: PASS - GAIN: %0d,%0d,%0d",
                pipe[0].GAIN, pipe[1].GAIN, pipe[2].GAIN);
            pass_count++;
        end else
            $display("T3: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count >= 2)
            $display("PASS: test_gen_nested_call");
        else
            $display("FAIL: test_gen_nested_call (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
