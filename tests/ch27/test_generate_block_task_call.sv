/*
:name: test_generate_block_task_call
:description: Tasks declared in loop generate blocks, called by hierarchical name (IEEE 1800-2023 Sections 27.4 and 23.6)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_block_task_call.expected
*/
// Tasks declared in loop generate blocks, called by hierarchical name; each
// task uses the localparam of its own generate block
// (IEEE 1800-2023 Sections 27.4 and 23.6)
module test_generate_block_task_call;
    int pass_count = 0;
    int result[4];

    parameter N = 4;

    // Generate block with local task
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : gen_block
            localparam int OFFSET = gi * 100;

            task automatic set_result(input int val);
                result[gi] = val + OFFSET;
            endtask
        end
    endgenerate

    initial begin
        #1;

        // T1: Call tasks from different generate instances
        gen_block[0].set_result(1);
        gen_block[1].set_result(1);
        gen_block[2].set_result(1);
        gen_block[3].set_result(1);
        #1;
        if (result[0] == 1 && result[1] == 101 &&
            result[2] == 201 && result[3] == 301) begin
            $display("T1: PASS - gen task results: %0d, %0d, %0d, %0d",
                result[0], result[1], result[2], result[3]);
            pass_count++;
        end else
            $display("T1: FAIL - results: %0d, %0d, %0d, %0d",
                result[0], result[1], result[2], result[3]);

        // T2: Call with different values
        gen_block[0].set_result(5);
        gen_block[3].set_result(5);
        #1;
        if (result[0] == 5 && result[3] == 305) begin
            $display("T2: PASS - [0]=%0d [3]=%0d", result[0], result[3]);
            pass_count++;
        end else
            $display("T2: FAIL - [0]=%0d [3]=%0d", result[0], result[3]);


        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 2)
            $display("PASS: test_generate_block_task_call");
        else
            $display("FAIL: test_generate_block_task_call (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
