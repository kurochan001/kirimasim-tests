/*
:name: test_generate_loop
:description: Test: Generate loop constructs
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop.expected
*/
// Test: Generate loop constructs
// IEEE 1800-2023 Section 27.4

module test_generate_loop;

    parameter N = 4;

    // Test 1: Generate for loop with module instances
    wire [N-1:0] test1_out;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_loop1
            assign test1_out[i] = 1'b1;
        end
    endgenerate

    // Test 2: Generate for loop with different indices
    logic [7:0] test2_arr [0:3];
    generate
        for (genvar j = 0; j < 4; j = j + 1) begin : gen_loop2
            initial test2_arr[j] = j * 10;
        end
    endgenerate

    // Test 3: Nested generate loops
    parameter M = 2;
    logic [M-1:0][N-1:0][7:0] matrix;
    generate
        for (genvar r = 0; r < M; r = r + 1) begin : row_gen
            for (genvar c = 0; c < N; c = c + 1) begin : col_gen
                initial matrix[r][c] = (r * N) + c;
            end
        end
    endgenerate

    // Test 4: Generate loop with local parameters
    logic [3:0] local_param_test;
    generate
        for (genvar k = 0; k < 4; k = k + 1) begin : gen_local
            localparam int OFFSET = k * 2;
            initial local_param_test[k] = (OFFSET > 2) ? 1'b1 : 1'b0;
        end
    endgenerate

    // Test 5: Generate loop accessing loop variable
    logic [15:0] loop_var_test;
    generate
        for (genvar m = 0; m < 16; m = m + 1) begin : gen_access
            assign loop_var_test[m] = (m % 2 == 0) ? 1'b1 : 1'b0;
        end
    endgenerate

    initial begin
        #1;

        // Test 1
        if (test1_out == 4'b1111) begin
            $display("PASS: test1_generate_for - All outputs set to 1");
        end else begin
            $display("FAIL: test1_generate_for - Expected 1111, got %b", test1_out);
        end

        // Test 2
        if (test2_arr[0] == 0 && test2_arr[1] == 10 &&
            test2_arr[2] == 20 && test2_arr[3] == 30) begin
            $display("PASS: test2_array_init - Arrays initialized correctly");
        end else begin
            $display("FAIL: test2_array_init - Array values incorrect");
        end

        // Test 3
        if (matrix[0][0] == 0 && matrix[0][3] == 3 &&
            matrix[1][0] == 4 && matrix[1][3] == 7) begin
            $display("PASS: test3_nested_loops - Matrix initialized correctly");
        end else begin
            $display("FAIL: test3_nested_loops - Matrix values incorrect");
        end

        // Test 4
        if (local_param_test == 4'b1100) begin
            $display("PASS: test4_local_params - Local parameters work");
        end else begin
            $display("FAIL: test4_local_params - Expected 1100, got %b", local_param_test);
        end

        // Test 5
        if (loop_var_test == 16'b0101010101010101) begin
            $display("PASS: test5_loop_variable - Loop variable access works");
        end else begin
            $display("FAIL: test5_loop_variable - Expected alternating pattern");
        end

        $finish;
    end
endmodule
