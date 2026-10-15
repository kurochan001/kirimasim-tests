/*
:name: test_comb_generate_nested
:description: Test: Nested generate loops with cross-references and task scoping
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.3 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_generate_nested.expected
*/
// Test: Nested generate loops with cross-references and task scoping
// Verifies IEEE 1800-2023 §27.4 generate loops, §27.3 conditional generate
module test_comb_generate_nested;
    int pass_count = 0;

    parameter N = 3;
    parameter M = 2;

    // Generate 2D array of signals
    logic [7:0] matrix[N][M];

    genvar gi, gj;
    generate
        for (gi = 0; gi < N; gi++) begin : row_gen
            for (gj = 0; gj < M; gj++) begin : col_gen
                assign matrix[gi][gj] = gi * 10 + gj;
            end
        end
    endgenerate

    // Generate conditional
    parameter USE_PARITY = 1;
    logic parity_out;

    generate
        if (USE_PARITY) begin : parity_gen
            assign parity_out = matrix[0][0] ^ matrix[0][1];
        end else begin : no_parity_gen
            assign parity_out = 0;
        end
    endgenerate

    // Generate with local parameters
    generate
        for (gi = 0; gi < N; gi++) begin : sum_gen
            localparam int ROW_BASE = gi * 10;
            logic [15:0] row_sum;
            assign row_sum = matrix[gi][0] + matrix[gi][1];
        end
    endgenerate

    initial begin
        #1;

        // T1: 2D generate matrix values
        if (matrix[0][0] == 0 && matrix[0][1] == 1 &&
            matrix[1][0] == 10 && matrix[1][1] == 11 &&
            matrix[2][0] == 20 && matrix[2][1] == 21) begin
            $display("T1: PASS - 2D generate matrix correct");
            pass_count++;
        end else begin
            $display("T1: FAIL - matrix[0][0]=%0d [1][0]=%0d [2][1]=%0d",
                matrix[0][0], matrix[1][0], matrix[2][1]);
        end

        // T2: Conditional generate (parity XOR)
        begin
            // parity of matrix[0][0] ^ matrix[0][1] = 0 ^ 1 = 1
            if (parity_out == (matrix[0][0] ^ matrix[0][1])) begin
                $display("T2: PASS - parity_out = %h", parity_out);
                pass_count++;
            end else
                $display("T2: FAIL - parity_out = %h", parity_out);
        end

        // T3: Generate with localparam - row sums
        if (sum_gen[0].row_sum == 1 &&
            sum_gen[1].row_sum == 21 &&
            sum_gen[2].row_sum == 41) begin
            $display("T3: PASS - row sums: %0d, %0d, %0d",
                sum_gen[0].row_sum, sum_gen[1].row_sum, sum_gen[2].row_sum);
            pass_count++;
        end else begin
            $display("T3: FAIL - row sums: %0d, %0d, %0d",
                sum_gen[0].row_sum, sum_gen[1].row_sum, sum_gen[2].row_sum);
        end

        // T4: Direct matrix access via indices
        if (matrix[1][0] == 10) begin
            $display("T4: PASS - matrix[1][0] = %0d", matrix[1][0]);
            pass_count++;
        end else
            $display("T4: FAIL - matrix[1][0] = %0d", matrix[1][0]);

        // T5: Generate loop edge - last element
        if (matrix[N-1][M-1] == (N-1)*10 + (M-1)) begin
            $display("T5: PASS - last element matrix[%0d][%0d] = %0d", N-1, M-1, matrix[N-1][M-1]);
            pass_count++;
        end else
            $display("T5: FAIL");

        // T6: Multiple generates don't interfere - localparam access
        if (sum_gen[0].ROW_BASE == 0 &&
            sum_gen[1].ROW_BASE == 10 &&
            sum_gen[2].ROW_BASE == 20) begin
            $display("T6: PASS - localparams: %0d, %0d, %0d",
                sum_gen[0].ROW_BASE, sum_gen[1].ROW_BASE, sum_gen[2].ROW_BASE);
            pass_count++;
        end else
            $display("T6: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_generate_nested");
        else
            $display("FAIL: test_comb_generate_nested (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
