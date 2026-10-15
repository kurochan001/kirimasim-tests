/*
:name: test_comb_generate_blocks
:description: Parameterized generate with $clog2
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 27.6 20.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_generate_blocks.expected
*/
module test_comb_generate_blocks;
    int pass_count;

    // Parameterized generate with $clog2
    parameter int WIDTH = 16;
    parameter int DEPTH = 256;
    localparam int ADDR_W = $clog2(DEPTH);

    logic [WIDTH-1:0] mem_data;
    logic [ADDR_W-1:0] mem_addr;

    // Generate if with parameter expression
    generate
        if (WIDTH > 8) begin : wide_path
            logic [WIDTH-1:0] wide_reg;
            assign wide_reg = mem_data;
        end else begin : narrow_path
            logic [7:0] narrow_reg;
            assign narrow_reg = mem_data[7:0];
        end
    endgenerate

    // Generate for loop
    parameter int N_CHANNELS = 4;
    logic [7:0] channel_data[N_CHANNELS];
    logic [7:0] channel_out[N_CHANNELS];

    generate
        for (genvar i = 0; i < N_CHANNELS; i++) begin : ch_gen
            assign channel_out[i] = channel_data[i] + 8'(i);
        end
    endgenerate

    // Generate case
    parameter int MODE = 2;
    generate
        case (MODE)
            0: begin : mode0
                logic mode0_sig;
            end
            1: begin : mode1
                logic mode1_sig;
            end
            2: begin : mode2
                logic mode2_sig;
                assign mode2_sig = 1'b1;
            end
            default: begin : mode_def
                logic default_sig;
            end
        endcase
    endgenerate

    // Nested generate
    parameter int ROWS = 2;
    parameter int COLS = 3;
    logic [7:0] grid[ROWS][COLS];
    logic [7:0] grid_out[ROWS][COLS];

    generate
        for (genvar r = 0; r < ROWS; r++) begin : row_gen
            for (genvar c = 0; c < COLS; c++) begin : col_gen
                assign grid_out[r][c] = grid[r][c] ^ 8'(r * COLS + c);
            end
        end
    endgenerate

    // Generate with conditional parameter
    parameter bit ENABLE_PARITY = 1;
    logic [7:0] parity_data;
    logic parity_bit;

    generate
        if (ENABLE_PARITY) begin : parity_gen
            assign parity_bit = ^parity_data;
        end
    endgenerate

    // Generate with localparam calculation
    parameter int BUS_W = 32;
    localparam int BYTE_LANES = BUS_W / 8;
    logic [7:0] byte_lanes[BYTE_LANES];
    logic [BUS_W-1:0] bus_data;

    generate
        for (genvar b = 0; b < BYTE_LANES; b++) begin : byte_gen
            assign byte_lanes[b] = bus_data[b*8 +: 8];
        end
    endgenerate

    initial begin
        pass_count = 0;

        // Test 1: $clog2 parameter
        if (ADDR_W == 8) pass_count++;

        // Test 2: Generate if selected wide path
        mem_data = 16'hABCD;
        #1;
        if (wide_path.wide_reg == 16'hABCD) pass_count++;

        // Test 3: Generate for channel processing
        for (int i = 0; i < N_CHANNELS; i++) channel_data[i] = 8'h10;
        #1;
        if (channel_out[0] == 8'h10 && channel_out[3] == 8'h13) pass_count++;

        // Test 4: Generate case selected mode2
        #1;
        if (mode2.mode2_sig == 1'b1) pass_count++;

        // Test 5: Nested generate grid
        for (int r = 0; r < ROWS; r++)
            for (int c = 0; c < COLS; c++)
                grid[r][c] = 8'hFF;
        #1;
        if (grid_out[0][0] == (8'hFF ^ 8'd0)) pass_count++;
        if (grid_out[1][2] == (8'hFF ^ 8'd5)) pass_count++;

        // Test 6: Parity generation
        parity_data = 8'hA5;  // 10100101 -> even parity -> 0
        #1;
        if (parity_bit == 1'b0) pass_count++;

        // Test 7: Byte lane extraction
        bus_data = 32'hDEADBEEF;
        #1;
        if (byte_lanes[0] == 8'hEF && byte_lanes[3] == 8'hDE) pass_count++;

        // Test 8: BYTE_LANES localparam
        if (BYTE_LANES == 4) pass_count++;

        $display("pass_count = %0d", pass_count);
        if (pass_count == 9)
            $display("PASS: test_comb_generate_blocks");
        else
            $display("FAIL: test_comb_generate_blocks (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
