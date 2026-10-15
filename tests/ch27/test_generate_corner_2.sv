/*
:name: test_generate_corner_2
:description: Loop, if and case generate constructs, and hierarchical access into them
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_corner_2.expected
*/
// Loop, if and case generate constructs, and hierarchical access into them
`timescale 1ns/1ps

module test_generate_corner;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    always #5 clk = ~clk;

    parameter int NUM_STAGES = 4;
    parameter int MODE = 2;

    logic [7:0] stage_in;
    logic [7:0] stage_out[NUM_STAGES];

    // Generate for loop
    genvar i;
    generate
        for (i = 0; i < NUM_STAGES; i++) begin : gen_stages
            logic [7:0] local_reg;

            if (i == 0) begin : first_stage
                always @(posedge clk) begin
                    local_reg <= stage_in;
                end
            end else begin : other_stages
                always @(posedge clk) begin
                    local_reg <= gen_stages[i-1].local_reg;
                end
            end

            assign stage_out[i] = local_reg;
        end
    endgenerate

    // Generate if
    generate
        if (MODE == 1) begin : mode1_logic
            logic [7:0] mode_val = 8'h11;
        end else if (MODE == 2) begin : mode2_logic
            logic [7:0] mode_val = 8'h22;
        end else begin : default_logic
            logic [7:0] mode_val = 8'hFF;
        end
    endgenerate

    // Generate case
    generate
        case (NUM_STAGES)
            1: begin : single_stage
                logic is_single = 1;
            end
            2, 3: begin : few_stages
                logic is_few = 1;
            end
            default: begin : many_stages
                logic is_many = 1;
            end
        endcase
    endgenerate

    // Test 1: Pipeline stages
    task test_pipeline();
        stage_in = 8'hAB;
        repeat (NUM_STAGES + 1) @(posedge clk);

        if (stage_out[NUM_STAGES-1] == 8'hAB) begin
            $display("PASS: Generate for loop pipeline works");
            pass_count++;
        end else begin
            $display("FAIL: Pipeline output = %h (expected 0xAB)", stage_out[NUM_STAGES-1]);
            fail_count++;
        end
    endtask

    // Test 2: Intermediate stages
    task test_intermediate_stages();
        stage_in = 8'hCD;
        @(posedge clk);
        @(posedge clk);  // Two stages propagated

        if (stage_out[0] == 8'hCD) begin
            $display("PASS: First stage captures input");
            pass_count++;
        end else begin
            $display("FAIL: First stage = %h", stage_out[0]);
            fail_count++;
        end
    endtask

    // Test 3: Generate if mode selection
    task test_generate_if();
        if (mode2_logic.mode_val == 8'h22) begin
            $display("PASS: Generate if selected MODE 2");
            pass_count++;
        end else begin
            $display("FAIL: Generate if mode selection wrong");
            fail_count++;
        end
    endtask

    // Test 4: Generate case selection
    task test_generate_case();
        if (many_stages.is_many == 1) begin
            $display("PASS: Generate case selected many_stages (NUM_STAGES=%0d)", NUM_STAGES);
            pass_count++;
        end else begin
            $display("FAIL: Generate case selection wrong");
            fail_count++;
        end
    endtask

    // Test 5: Hierarchical access to generated logic
    task test_hierarchical_access();
        // Write gen_stages[0].local_reg away from a clock edge, so that the
        // nonblocking assignment of that edge does not overwrite it.
        #1;
        gen_stages[0].local_reg = 8'h55;
        #1;
        if (stage_out[0] == 8'h55) begin
            $display("PASS: Hierarchical access to generate block works");
            pass_count++;
        end else begin
            $display("FAIL: stage_out[0] = %h", stage_out[0]);
            fail_count++;
        end
        @(posedge clk);
    endtask

    // Test 6: Multiple data propagation
    task test_data_propagation();
        // The input changes on falling edges, away from the rising edges
        // that sample it, so the values taken do not depend on process order.
        stage_in = 8'h00;
        repeat (NUM_STAGES + 2) @(posedge clk);

        @(negedge clk) stage_in = 8'hFF;
        @(negedge clk) stage_in = 8'h11;
        @(negedge clk) stage_in = 8'h22;
        @(negedge clk);

        if (stage_out[0] == 8'h22 && stage_out[1] == 8'h11 &&
            stage_out[2] == 8'hFF && stage_out[3] == 8'h00) begin
            $display("PASS: Data propagation through pipeline");
            pass_count++;
        end else begin
            $display("FAIL: stages %h %h %h %h", stage_out[0], stage_out[1],
                     stage_out[2], stage_out[3]);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Generate Construct Corner Cases Test ===");

        repeat (2) @(posedge clk);

        test_pipeline();
        test_intermediate_stages();
        test_generate_if();
        test_generate_case();
        test_hierarchical_access();
        test_data_propagation();

        repeat (3) @(posedge clk);

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
