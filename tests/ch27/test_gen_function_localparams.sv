/*
:name: test_gen_function_localparams
:description: Per-instance functions in a generate loop that use several localparams
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 13.4 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gen_function_localparams.expected
*/
// Per-instance functions in a generate loop that use several localparams
module test_gen_function_localparams;
    int pass_count = 0;

    parameter N = 4;
    logic [15:0] input_val[N];
    logic [15:0] output_val[N];

    // Generate with function using multiple localparams
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : proc
            localparam int CHANNEL_ID = gi;
            localparam int BASE_ADDR = gi * 16'h1000;
            localparam int MASK = (1 << (gi + 1)) - 1;

            function automatic logic [15:0] process(logic [15:0] val);
                logic [15:0] result;
                result = (val & MASK) + BASE_ADDR;
                return result;
            endfunction

            assign output_val[gi] = process(input_val[gi]);
        end
    endgenerate

    initial begin
        #1;

        // T1: Process with input 0xFF
        // MASK: [0]=0x1, [1]=0x3, [2]=0x7, [3]=0xF
        // BASE: [0]=0x0000, [1]=0x1000, [2]=0x2000, [3]=0x3000
        for (int i = 0; i < N; i++) input_val[i] = 16'h00FF;
        #1;
        // [0]: 0xFF & 0x1 + 0x0000 = 0x0001
        // [1]: 0xFF & 0x3 + 0x1000 = 0x1003
        // [2]: 0xFF & 0x7 + 0x2000 = 0x2007
        // [3]: 0xFF & 0xF + 0x3000 = 0x300F
        if (output_val[0] == 16'h0001 && output_val[1] == 16'h1003 &&
            output_val[2] == 16'h2007 && output_val[3] == 16'h300F) begin
            $display("T1: PASS - process: %h,%h,%h,%h",
                output_val[0], output_val[1], output_val[2], output_val[3]);
            pass_count++;
        end else
            $display("T1: FAIL - %h,%h,%h,%h",
                output_val[0], output_val[1], output_val[2], output_val[3]);

        // T2: Process with input 0
        for (int i = 0; i < N; i++) input_val[i] = 16'h0000;
        #1;
        // All: 0 & MASK + BASE = BASE
        if (output_val[0] == 16'h0000 && output_val[1] == 16'h1000 &&
            output_val[2] == 16'h2000 && output_val[3] == 16'h3000) begin
            $display("T2: PASS - zero input: %h,%h,%h,%h",
                output_val[0], output_val[1], output_val[2], output_val[3]);
            pass_count++;
        end else
            $display("T2: FAIL - %h,%h,%h,%h",
                output_val[0], output_val[1], output_val[2], output_val[3]);

        // T3: Hierarchical access to localparams
        if (proc[0].BASE_ADDR == 16'h0000 && proc[1].BASE_ADDR == 16'h1000 &&
            proc[2].BASE_ADDR == 16'h2000 && proc[3].BASE_ADDR == 16'h3000) begin
            $display("T3: PASS - BASE_ADDR: %h,%h,%h,%h",
                proc[0].BASE_ADDR, proc[1].BASE_ADDR,
                proc[2].BASE_ADDR, proc[3].BASE_ADDR);
            pass_count++;
        end else
            $display("T3: FAIL");

        // T4: MASK values
        if (proc[0].MASK == 1 && proc[1].MASK == 3 &&
            proc[2].MASK == 7 && proc[3].MASK == 15) begin
            $display("T4: PASS - MASK: %0d,%0d,%0d,%0d",
                proc[0].MASK, proc[1].MASK, proc[2].MASK, proc[3].MASK);
            pass_count++;
        end else
            $display("T4: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count >= 3)
            $display("PASS: test_gen_function_localparams");
        else
            $display("FAIL: test_gen_function_localparams (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
