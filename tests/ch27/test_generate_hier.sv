/*
:name: test_generate_hier
:description: Hierarchical access to variables in loop, if and case generate blocks
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_hier.expected
*/
// Hierarchical access to variables in loop, if and case generate blocks
module test_generate_hier;
    int pass_count = 0;
    int total_tests = 8;

    parameter int NUM_UNITS = 4;

    logic [7:0] data_array [NUM_UNITS];
    logic [7:0] result;

    // Generate block with for loop
    generate
        genvar i;
        for (i = 0; i < NUM_UNITS; i++) begin : gen_unit
            logic [7:0] local_data;
            logic unit_valid;

            assign local_data = data_array[i] + i;
        end
    endgenerate

    // Conditional generate
    generate
        if (NUM_UNITS > 2) begin : gen_large
            logic [15:0] large_counter;
        end else begin : gen_small
            logic [7:0] small_counter;
        end
    endgenerate

    // Case generate
    generate
        case (NUM_UNITS)
            1: begin : gen_case_1
                logic single_mode;
            end
            4: begin : gen_case_4
                logic quad_mode;
            end
            default: begin : gen_case_default
                logic default_mode;
            end
        endcase
    endgenerate

    initial begin
        // Initialize data array
        for (int j = 0; j < NUM_UNITS; j++) begin
            data_array[j] = j * 10;
        end

        #1;

        // Test 1: Access generate block signal (unit 0)
        if (gen_unit[0].local_data == 8'h00) begin
            $display("Test 1 PASS: gen_unit[0].local_data = %h", gen_unit[0].local_data);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: gen_unit[0].local_data = %h, expected 00", gen_unit[0].local_data);
        end

        // Test 2: Access generate block signal (unit 1)
        if (gen_unit[1].local_data == 8'h0B) begin  // 10 + 1 = 11
            $display("Test 2 PASS: gen_unit[1].local_data = %h", gen_unit[1].local_data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: gen_unit[1].local_data = %h, expected 0B", gen_unit[1].local_data);
        end

        // Test 3: Access generate block signal (unit 2)
        if (gen_unit[2].local_data == 8'h16) begin  // 20 + 2 = 22
            $display("Test 3 PASS: gen_unit[2].local_data = %h", gen_unit[2].local_data);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: gen_unit[2].local_data = %h, expected 16", gen_unit[2].local_data);
        end

        // Test 4: Access generate block signal (unit 3)
        if (gen_unit[3].local_data == 8'h21) begin  // 30 + 3 = 33
            $display("Test 4 PASS: gen_unit[3].local_data = %h", gen_unit[3].local_data);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: gen_unit[3].local_data = %h, expected 21", gen_unit[3].local_data);
        end

        // Test 5: Conditional generate (large case)
        gen_large.large_counter = 16'hABCD;
        #1;
        if (gen_large.large_counter == 16'hABCD) begin
            $display("Test 5 PASS: gen_large.large_counter = %h", gen_large.large_counter);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: gen_large.large_counter = %h, expected ABCD", gen_large.large_counter);
        end

        // Test 6: Case generate (quad mode)
        gen_case_4.quad_mode = 1'b1;
        #1;
        if (gen_case_4.quad_mode == 1'b1) begin
            $display("Test 6 PASS: gen_case_4.quad_mode = %b", gen_case_4.quad_mode);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: gen_case_4.quad_mode = %b, expected 1", gen_case_4.quad_mode);
        end

        // Test 7: Write to generate block unit_valid
        gen_unit[0].unit_valid = 1'b1;
        gen_unit[1].unit_valid = 1'b0;
        #1;
        if (gen_unit[0].unit_valid == 1'b1 && gen_unit[1].unit_valid == 1'b0) begin
            $display("Test 7 PASS: gen_unit valid flags set correctly");
            pass_count++;
        end else begin
            $display("Test 7 FAIL: gen_unit valid flags incorrect");
        end

        // Test 8: Update source and check propagation
        data_array[0] = 8'h50;
        #1;
        if (gen_unit[0].local_data == 8'h50) begin  // 80 + 0 = 80
            $display("Test 8 PASS: Propagation through generate block");
            pass_count++;
        end else begin
            $display("Test 8 FAIL: gen_unit[0].local_data = %h, expected 50", gen_unit[0].local_data);
        end

        $display("PASS: generate_hier (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
