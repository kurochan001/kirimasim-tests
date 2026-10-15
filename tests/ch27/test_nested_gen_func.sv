/*
:name: test_nested_gen_func
:description: Nested generate block with functions
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 13.4 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_gen_func.expected
*/
// Nested generate block with functions
module test_nested_gen_func;
    int pass_count = 0;

    parameter ROWS = 2;
    parameter COLS = 3;
    logic [7:0] matrix[ROWS][COLS];
    logic [7:0] transformed[ROWS][COLS];

    // Nested generate blocks with per-instance functions
    genvar ri, ci;
    generate
        for (ri = 0; ri < ROWS; ri++) begin : row_gen
            for (ci = 0; ci < COLS; ci++) begin : col_gen
                localparam int SCALE = (ri + 1) * (ci + 1);

                function automatic logic [7:0] scale_val(logic [7:0] val);
                    return val * SCALE;
                endfunction

                assign transformed[ri][ci] = scale_val(matrix[ri][ci]);
            end
        end
    endgenerate

    initial begin
        #1;

        // T1: Set all matrix elements to 1, check scaling
        for (int i = 0; i < ROWS; i++)
            for (int j = 0; j < COLS; j++)
                matrix[i][j] = 8'd1;
        #1;

        // Expected: transformed[r][c] = 1 * (r+1)*(c+1)
        // [0][0]=1, [0][1]=2, [0][2]=3
        // [1][0]=2, [1][1]=4, [1][2]=6
        if (transformed[0][0] == 1 && transformed[0][1] == 2 && transformed[0][2] == 3 &&
            transformed[1][0] == 2 && transformed[1][1] == 4 && transformed[1][2] == 6) begin
            $display("T1: PASS - nested gen scale: [0]=%0d,%0d,%0d [1]=%0d,%0d,%0d",
                transformed[0][0], transformed[0][1], transformed[0][2],
                transformed[1][0], transformed[1][1], transformed[1][2]);
            pass_count++;
        end else begin
            $display("T1: FAIL - [0]=%0d,%0d,%0d [1]=%0d,%0d,%0d",
                transformed[0][0], transformed[0][1], transformed[0][2],
                transformed[1][0], transformed[1][1], transformed[1][2]);
        end

        // T2: Set matrix to 2, verify different scaling
        for (int i = 0; i < ROWS; i++)
            for (int j = 0; j < COLS; j++)
                matrix[i][j] = 8'd2;
        #1;
        if (transformed[0][0] == 2 && transformed[1][2] == 12) begin
            $display("T2: PASS - scale(2): [0][0]=%0d [1][2]=%0d", transformed[0][0], transformed[1][2]);
            pass_count++;
        end else
            $display("T2: FAIL - [0][0]=%0d [1][2]=%0d", transformed[0][0], transformed[1][2]);

        // T3: Hierarchical localparam access
        if (row_gen[0].col_gen[0].SCALE == 1 &&
            row_gen[0].col_gen[2].SCALE == 3 &&
            row_gen[1].col_gen[1].SCALE == 4 &&
            row_gen[1].col_gen[2].SCALE == 6) begin
            $display("T3: PASS - nested SCALE: %0d,%0d,%0d,%0d",
                row_gen[0].col_gen[0].SCALE, row_gen[0].col_gen[2].SCALE,
                row_gen[1].col_gen[1].SCALE, row_gen[1].col_gen[2].SCALE);
            pass_count++;
        end else
            $display("T3: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 3)
            $display("PASS: test_nested_gen_func");
        else
            $display("FAIL: test_nested_gen_func (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
