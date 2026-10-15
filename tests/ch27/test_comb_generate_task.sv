/*
:name: test_comb_generate_task
:description: Test: Task/function scoping inside generate blocks
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_generate_task.expected
*/
// Test: Task/function scoping inside generate blocks
// Verifies IEEE 1800-2023 §27.4 generate loop with tasks/functions
module test_comb_generate_task;
    int pass_count = 0;

    parameter N = 4;
    logic [7:0] data[N];
    logic [7:0] result[N];

    // Generate block with local function
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : gen_block
            localparam int OFFSET = gi * 10;

            function automatic logic [7:0] transform(logic [7:0] val);
                return val + OFFSET;
            endfunction

            assign result[gi] = transform(data[gi]);
        end
    endgenerate

    // Generate with conditional instantiation
    parameter ENABLE_CHECK = 1;
    logic check_result;

    generate
        if (ENABLE_CHECK) begin : check_gen
            assign check_result = (data[0] != 0);
        end
    endgenerate

    initial begin
        #1;

        // T1: Generate function with localparam
        data[0] = 8'd5;
        data[1] = 8'd5;
        data[2] = 8'd5;
        data[3] = 8'd5;
        #1;
        if (result[0] == 5 && result[1] == 15 &&
            result[2] == 25 && result[3] == 35) begin
            $display("T1: PASS - generate transform: %0d, %0d, %0d, %0d",
                result[0], result[1], result[2], result[3]);
            pass_count++;
        end else begin
            $display("T1: FAIL - results: %0d, %0d, %0d, %0d",
                result[0], result[1], result[2], result[3]);
        end

        // T2: Each generate block has independent function
        data[0] = 8'd1;
        data[3] = 8'd1;
        #1;
        if (result[0] == 1 && result[3] == 31) begin
            $display("T2: PASS - independent functions: [0]=%0d [3]=%0d", result[0], result[3]);
            pass_count++;
        end else
            $display("T2: FAIL - [0]=%0d [3]=%0d", result[0], result[3]);

        // T3: Conditional generate block
        data[0] = 8'd10;
        #1;
        if (check_result == 1) begin
            $display("T3: PASS - check_result = %0b (data[0] != 0)", check_result);
            pass_count++;
        end else
            $display("T3: FAIL - check_result = %0b", check_result);

        // T4: Data[0] = 0 check
        data[0] = 8'd0;
        #1;
        if (check_result == 0) begin
            $display("T4: PASS - check_result = %0b (data[0] == 0)", check_result);
            pass_count++;
        end else
            $display("T4: FAIL - check_result = %0b", check_result);

        // T5: Hierarchical access to generate localparam
        if (gen_block[0].OFFSET == 0 && gen_block[2].OFFSET == 20) begin
            $display("T5: PASS - OFFSET[0]=%0d OFFSET[2]=%0d",
                gen_block[0].OFFSET, gen_block[2].OFFSET);
            pass_count++;
        end else
            $display("T5: FAIL");

        // T6: Generate with zero input
        data[0] = 0; data[1] = 0; data[2] = 0; data[3] = 0;
        #1;
        if (result[0] == 0 && result[1] == 10 &&
            result[2] == 20 && result[3] == 30) begin
            $display("T6: PASS - zero input + offset: %0d,%0d,%0d,%0d",
                result[0], result[1], result[2], result[3]);
            pass_count++;
        end else
            $display("T6: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_generate_task");
        else
            $display("FAIL: test_comb_generate_task (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
