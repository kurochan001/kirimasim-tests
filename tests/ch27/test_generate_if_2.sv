/*
:name: test_generate_if_2
:description: Generate if/else blocks
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_if_2.expected
*/
// Generate if/else blocks
module test_generate_if;
    int pass_count = 0;
    int fail_count = 0;

    parameter USE_FEATURE_A = 1;
    parameter USE_FEATURE_B = 0;
    parameter DATA_WIDTH = 16;

    logic [DATA_WIDTH-1:0] data;
    logic result_a, result_b;
    logic wide_mode;

    // Generate if for feature selection
    generate
        if (USE_FEATURE_A) begin : gen_feature_a
            assign result_a = 1'b1;
        end else begin : gen_no_feature_a
            assign result_a = 1'b0;
        end
    endgenerate

    // Generate if/else with parameter
    generate
        if (USE_FEATURE_B) begin : gen_feature_b
            assign result_b = 1'b1;
        end else begin : gen_no_feature_b
            assign result_b = 1'b0;
        end
    endgenerate

    // Generate if based on width
    generate
        if (DATA_WIDTH >= 16) begin : gen_wide
            assign wide_mode = 1'b1;
        end else begin : gen_narrow
            assign wide_mode = 1'b0;
        end
    endgenerate

    // Nested generate if
    logic nested_result;
    generate
        if (USE_FEATURE_A) begin : gen_outer
            if (DATA_WIDTH > 8) begin : gen_inner
                assign nested_result = 1'b1;
            end else begin : gen_inner_else
                assign nested_result = 1'b0;
            end
        end else begin : gen_outer_else
            assign nested_result = 1'b0;
        end
    endgenerate

    initial begin
        #1;

        // Test 1: Feature A enabled
        if (result_a == 1'b1) begin
            $display("PASS: Generate if - Feature A enabled");
            pass_count++;
        end else begin
            $display("FAIL: Feature A - expected 1, got %0d", result_a);
            fail_count++;
        end

        // Test 2: Feature B disabled
        if (result_b == 1'b0) begin
            $display("PASS: Generate if - Feature B disabled");
            pass_count++;
        end else begin
            $display("FAIL: Feature B - expected 0, got %0d", result_b);
            fail_count++;
        end

        // Test 3: Width-based generate
        if (wide_mode == 1'b1) begin
            $display("PASS: Generate if - Wide mode (DATA_WIDTH=%0d)", DATA_WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: Wide mode - expected 1, got %0d", wide_mode);
            fail_count++;
        end

        // Test 4: Nested generate
        if (nested_result == 1'b1) begin
            $display("PASS: Nested generate if");
            pass_count++;
        end else begin
            $display("FAIL: Nested generate - expected 1, got %0d", nested_result);
            fail_count++;
        end

        // Test 5: Data width parameter
        data = '1;
        if ($bits(data) == DATA_WIDTH) begin
            $display("PASS: Generate with parameterized width");
            pass_count++;
        end else begin
            $display("FAIL: Data width - expected %0d, got %0d", DATA_WIDTH, $bits(data));
            fail_count++;
        end

        // Summary
        $display("Generate if test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All generate if tests passed");
        $finish;
    end
endmodule
