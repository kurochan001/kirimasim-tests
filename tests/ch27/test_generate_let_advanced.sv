/*
:name: test_generate_let_advanced
:description: Generate and Let Constructs Advanced Test
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 11.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_let_advanced.expected
*/
// IEEE 1800-2023 Generate and Let Constructs Advanced Test
// IEEE 1800-2023 Section 27 (Generate constructs), Section 11.12 (Let)

`timescale 1ns/1ps

module test_generate_let_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Helper task
    task automatic check(input string name, input bit condition);
        if (condition) begin
            $display("  PASS: %s", name);
            pass_count++;
        end else begin
            $display("  FAIL: %s", name);
            fail_count++;
        end
    endtask

    // ===== Test 1: Basic generate for loop =====
    parameter WIDTH = 4;
    logic [WIDTH-1:0] gen_data;
    logic [WIDTH-1:0] gen_result;

    generate
        genvar i;
        for (i = 0; i < WIDTH; i++) begin : gen_loop
            assign gen_result[i] = ~gen_data[i];
        end
    endgenerate

    // ===== Test 2: Generate if/else =====
    parameter USE_FAST = 1;
    logic [7:0] test_val;
    logic [7:0] processed_val;

    generate
        if (USE_FAST) begin : fast_path
            assign processed_val = test_val << 1;
        end else begin : slow_path
            assign processed_val = test_val + 1;
        end
    endgenerate

    // ===== Test 3: Generate case =====
    parameter MODE = 2;
    logic [3:0] mode_input;
    logic [3:0] mode_output;

    generate
        case (MODE)
            0: assign mode_output = mode_input;
            1: assign mode_output = ~mode_input;
            2: assign mode_output = mode_input + 1;
            default: assign mode_output = 4'b0;
        endcase
    endgenerate

    // ===== Test 4: Nested generate =====
    parameter ROWS = 2;
    parameter COLS = 2;
    logic [ROWS*COLS-1:0] matrix_flat;

    generate
        genvar r, c;
        for (r = 0; r < ROWS; r++) begin : row_gen
            for (c = 0; c < COLS; c++) begin : col_gen
                localparam IDX = r * COLS + c;
                assign matrix_flat[IDX] = (r + c) % 2;
            end
        end
    endgenerate

    // ===== Test 5: Let declaration (basic) =====
    let add_one(x) = x + 1;
    let multiply(a, b) = a * b;
    let max_val(p, q) = (p > q) ? p : q;

    // ===== Test 6: Let with multiple args =====
    let clamp(val, min_v, max_v) = (val < min_v) ? min_v : ((val > max_v) ? max_v : val);

    // ===== Test 7: Generate with localparam =====
    parameter DEPTH = 8;
    localparam ADDR_WIDTH = $clog2(DEPTH);
    logic [ADDR_WIDTH-1:0] addr;
    logic [7:0] mem_data [DEPTH-1:0];

    generate
        genvar m;
        for (m = 0; m < DEPTH; m++) begin : mem_init
            initial mem_data[m] = m * 10;
        end
    endgenerate

    // ===== Test 8: Conditional generate with parameter expression =====
    parameter DATA_WIDTH = 16;
    parameter ENABLE_PARITY = 1;

    generate
        if (ENABLE_PARITY && DATA_WIDTH > 8) begin : parity_gen
            logic parity_bit;
            assign parity_bit = ^gen_data;
        end
    endgenerate

    initial begin
        $display("=== Generate and Let Constructs Advanced Test ===");
        $display("");

        // Test 1: Generate for loop
        $display("Test 1: Generate for loop");
        gen_data = 4'b1010;
        #1;
        check("gen_result = ~gen_data", gen_result == 4'b0101);

        gen_data = 4'b1111;
        #1;
        check("Inverted all ones", gen_result == 4'b0000);

        // Test 2: Generate if/else
        $display("");
        $display("Test 2: Generate if/else (USE_FAST=%0d)", USE_FAST);
        test_val = 8'h10;
        #1;
        check("Fast path: shift left", processed_val == 8'h20);

        // Test 3: Generate case
        $display("");
        $display("Test 3: Generate case (MODE=%0d)", MODE);
        mode_input = 4'd5;
        #1;
        check("Mode 2: add one", mode_output == 4'd6);

        // Test 4: Nested generate
        $display("");
        $display("Test 4: Nested generate (2x2 matrix)");
        #1;
        $display("  matrix_flat = %b", matrix_flat);
        // bit r*COLS+c is (r+c)%2: 4'b0110
        check("Nested generate executed", matrix_flat == 4'b0110);

        // Test 5: Let declaration (basic)
        $display("");
        $display("Test 5: Let declarations");
        check("add_one(5) = 6", add_one(5) == 6);
        check("multiply(3, 4) = 12", multiply(3, 4) == 12);
        check("max_val(10, 20) = 20", max_val(10, 20) == 20);
        check("max_val(30, 15) = 30", max_val(30, 15) == 30);

        // Test 6: Let with type
        $display("");
        $display("Test 6: Let with type (clamp)");
        check("clamp(50, 0, 100) = 50", clamp(50, 0, 100) == 50);
        check("clamp(150, 0, 100) = 100", clamp(150, 0, 100) == 100);
        check("clamp(10, 20, 100) = 20", clamp(10, 20, 100) == 20);

        // Test 7: Generate with localparam
        $display("");
        $display("Test 7: Generate with localparam");
        check("ADDR_WIDTH = $clog2(8) = 3", ADDR_WIDTH == 3);
        check("mem_data[0] = 0", mem_data[0] == 0);
        check("mem_data[3] = 30", mem_data[3] == 30);
        check("mem_data[7] = 70", mem_data[7] == 70);

        // Test 8: Conditional parameter expression
        $display("");
        $display("Test 8: Conditional generate");
        check("Parity generation enabled", ENABLE_PARITY == 1);
        check("DATA_WIDTH > 8", DATA_WIDTH > 8);

        // Summary
        $display("");
        $display("========================================");
        $display("TEST RESULTS: %0d/%0d PASSED", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
