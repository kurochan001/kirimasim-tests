/*
:name: test_generate_for_2
:description: Generate for loops with genvar
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_for_2.expected
*/
// Generate for loops with genvar
module test_generate_for;
    int pass_count = 0;
    int fail_count = 0;

    parameter NUM_CHANNELS = 4;
    parameter WIDTH = 8;

    logic [WIDTH-1:0] channel_data [NUM_CHANNELS];
    logic [WIDTH-1:0] channel_result [NUM_CHANNELS];
    logic [NUM_CHANNELS-1:0] channel_valid;

    // Generate for loop to create multiple channels
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i++) begin : gen_channel
            assign channel_result[i] = channel_data[i] + i;
            assign channel_valid[i] = (channel_data[i] != 0);
        end
    endgenerate

    // Nested generate for loop
    parameter ROWS = 2;
    parameter COLS = 3;
    logic [7:0] matrix [ROWS][COLS];
    logic [7:0] matrix_doubled [ROWS][COLS];

    genvar r, c;
    generate
        for (r = 0; r < ROWS; r++) begin : gen_row
            for (c = 0; c < COLS; c++) begin : gen_col
                assign matrix_doubled[r][c] = matrix[r][c] << 1;
            end
        end
    endgenerate

    // Generate with conditional inside
    parameter ENABLE_PARITY = 1;
    logic [NUM_CHANNELS-1:0] parity;

    generate
        for (i = 0; i < NUM_CHANNELS; i++) begin : gen_parity
            if (ENABLE_PARITY) begin : gen_parity_enabled
                assign parity[i] = ^channel_data[i];
            end else begin : gen_parity_disabled
                assign parity[i] = 1'b0;
            end
        end
    endgenerate

    initial begin
        // Initialize channel data
        channel_data[0] = 8'd10;
        channel_data[1] = 8'd20;
        channel_data[2] = 8'd30;
        channel_data[3] = 8'd0;  // Zero to test valid

        // Initialize matrix
        matrix[0][0] = 8'd1; matrix[0][1] = 8'd2; matrix[0][2] = 8'd3;
        matrix[1][0] = 8'd4; matrix[1][1] = 8'd5; matrix[1][2] = 8'd6;

        #1;

        // Test 1: Channel result with index addition
        if (channel_result[0] == 10 && channel_result[1] == 21 &&
            channel_result[2] == 32 && channel_result[3] == 3) begin
            $display("PASS: Generate for - channel results");
            pass_count++;
        end else begin
            $display("FAIL: Channel results - [%0d,%0d,%0d,%0d]",
                     channel_result[0], channel_result[1], channel_result[2], channel_result[3]);
            fail_count++;
        end

        // Test 2: Channel valid flags
        if (channel_valid == 4'b0111) begin
            $display("PASS: Generate for - channel valid flags");
            pass_count++;
        end else begin
            $display("FAIL: Channel valid - expected 0111, got %04b", channel_valid);
            fail_count++;
        end

        // Test 3: Nested generate - matrix doubled
        if (matrix_doubled[0][0] == 2 && matrix_doubled[0][2] == 6 &&
            matrix_doubled[1][1] == 10 && matrix_doubled[1][2] == 12) begin
            $display("PASS: Nested generate for - matrix doubled");
            pass_count++;
        end else begin
            $display("FAIL: Matrix doubled - [0][0]=%0d, [1][2]=%0d",
                     matrix_doubled[0][0], matrix_doubled[1][2]);
            fail_count++;
        end

        // Test 4: Generate with parity
        // channel_data[0]=10=0000_1010, parity=0
        // channel_data[1]=20=0001_0100, parity=0
        if (parity[0] == ^8'd10 && parity[1] == ^8'd20) begin
            $display("PASS: Generate for with conditional - parity");
            pass_count++;
        end else begin
            $display("FAIL: Parity - expected [%0d,%0d], got [%0d,%0d]",
                     ^8'd10, ^8'd20, parity[0], parity[1]);
            fail_count++;
        end

        // Test 5: Verify NUM_CHANNELS instances
        if ($size(channel_result) == NUM_CHANNELS) begin
            $display("PASS: Generate for creates NUM_CHANNELS=%0d instances", NUM_CHANNELS);
            pass_count++;
        end else begin
            $display("FAIL: Instance count - expected %0d, got %0d", NUM_CHANNELS, $size(channel_result));
            fail_count++;
        end

        // Summary
        $display("Generate for test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All generate for tests passed");
        $finish;
    end
endmodule
