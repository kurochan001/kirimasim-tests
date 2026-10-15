/*
:name: test_gen_if_case
:description: Generate if/case with functions and tasks
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 23.8 13.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gen_if_case.expected
*/
// Generate if/case with functions and tasks
module test_gen_if_case;
    int pass_count = 0;

    parameter USE_ADD = 1;
    parameter MODE = 2;

    // Generate if with function
    generate
        if (USE_ADD) begin : add_block
            localparam int OFFSET = 100;

            function automatic int transform(int val);
                return val + OFFSET;
            endfunction
        end else begin : sub_block
            localparam int OFFSET = 200;

            function automatic int transform(int val);
                return val - OFFSET;
            endfunction
        end
    endgenerate

    // Generate case with task
    generate
        case (MODE)
            0: begin : mode0
                localparam int SCALE = 1;
                function automatic int scale(int val);
                    return val * SCALE;
                endfunction
            end
            1: begin : mode1
                localparam int SCALE = 10;
                function automatic int scale(int val);
                    return val * SCALE;
                endfunction
            end
            2: begin : mode2
                localparam int SCALE = 100;
                function automatic int scale(int val);
                    return val * SCALE;
                endfunction
            end
            default: begin : mode_default
                localparam int SCALE = 0;
                function automatic int scale(int val);
                    return val * SCALE;
                endfunction
            end
        endcase
    endgenerate

    int result_add, result_scale;

    initial begin
        #1;

        // T1: Generate if - function with localparam
        result_add = add_block.transform(5);
        if (result_add == 105) begin
            $display("T1: PASS - gen if transform: %0d", result_add);
            pass_count++;
        end else
            $display("T1: FAIL - transform=%0d (expect 105)", result_add);

        // T2: Generate case - function with localparam (MODE=2, SCALE=100)
        result_scale = mode2.scale(7);
        if (result_scale == 700) begin
            $display("T2: PASS - gen case scale: %0d", result_scale);
            pass_count++;
        end else
            $display("T2: FAIL - scale=%0d (expect 700)", result_scale);

        // T3: Hierarchical localparam access
        if (add_block.OFFSET == 100) begin
            $display("T3: PASS - OFFSET=%0d", add_block.OFFSET);
            pass_count++;
        end else
            $display("T3: FAIL - OFFSET=%0d", add_block.OFFSET);

        // T4: Case localparam access
        if (mode2.SCALE == 100) begin
            $display("T4: PASS - SCALE=%0d", mode2.SCALE);
            pass_count++;
        end else
            $display("T4: FAIL - SCALE=%0d", mode2.SCALE);

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 4)
            $display("PASS: test_gen_if_case");
        else
            $display("FAIL: test_gen_if_case (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
