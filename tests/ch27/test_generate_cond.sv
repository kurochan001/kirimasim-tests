/*
:name: test_generate_cond
:description: Test: Generate conditional constructs
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate_cond.expected
*/
// Test: Generate conditional constructs
// IEEE 1800-2023 Section 27.5

module test_generate_cond;

    parameter USE_FAST = 1;
    parameter WIDTH = 8;
    parameter ENABLE_DEBUG = 0;

    // Test 1: Basic if-generate
    logic [7:0] result1;
    generate
        if (USE_FAST) begin : fast_impl
            assign result1 = 8'hAA;
        end else begin : slow_impl
            assign result1 = 8'h55;
        end
    endgenerate

    // Test 2: If-generate without else
    logic [7:0] result2;
    generate
        if (WIDTH > 4) begin : wide_mode
            assign result2 = 8'hFF;
        end else begin : narrow_mode
            assign result2 = 8'h00;
        end
    endgenerate

    // Test 3: Nested if-generate
    logic [7:0] result3;
    generate
        if (USE_FAST) begin : outer_fast
            if (WIDTH >= 8) begin : inner_wide
                assign result3 = 8'hCC;
            end else begin : inner_narrow
                assign result3 = 8'h33;
            end
        end else begin : outer_slow
            assign result3 = 8'h11;
        end
    endgenerate

    // Test 4: Case-generate
    parameter MODE = 2;
    logic [7:0] result4;
    generate
        case (MODE)
            0: assign result4 = 8'h00;
            1: assign result4 = 8'h11;
            2: assign result4 = 8'h22;
            default: assign result4 = 8'hFF;
        endcase
    endgenerate

    // Test 5: Complex conditional with parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 16;
    logic use_narrow;
    generate
        if (DATA_WIDTH <= 16 && ADDR_WIDTH <= 8) begin : narrow_config
            initial use_narrow = 1'b1;
        end else if (DATA_WIDTH <= 32) begin : medium_config
            initial use_narrow = 1'b0;
        end else begin : wide_config
            initial use_narrow = 1'bx;
        end
    endgenerate

    initial begin
        #1;

        // Test 1
        if (result1 == 8'hAA) begin
            $display("PASS: test1_if_generate - Fast implementation selected");
        end else begin
            $display("FAIL: test1_if_generate - Expected AA, got %h", result1);
        end

        // Test 2
        if (result2 == 8'hFF) begin
            $display("PASS: test2_if_no_else - Wide mode activated");
        end else begin
            $display("FAIL: test2_if_no_else - Expected FF, got %h", result2);
        end

        // Test 3
        if (result3 == 8'hCC) begin
            $display("PASS: test3_nested_if - Correct path selected");
        end else begin
            $display("FAIL: test3_nested_if - Expected CC, got %h", result3);
        end

        // Test 4
        if (result4 == 8'h22) begin
            $display("PASS: test4_case_generate - Case 2 selected");
        end else begin
            $display("FAIL: test4_case_generate - Expected 22, got %h", result4);
        end

        // Test 5
        if (use_narrow == 1'b0) begin
            $display("PASS: test5_complex_cond - Medium config selected");
        end else begin
            $display("FAIL: test5_complex_cond - Wrong config selected");
        end

        $finish;
    end
endmodule
