/*
:name: test_generate_if_edge_cases
:description: Generate if edge cases
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_if_edge_cases.expected
*/
// IEEE 1800-2023 §27.5: Generate if edge cases
// Tests for conditional generate blocks

module test_generate_if_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    parameter USE_FAST = 1;
    parameter WIDTH = 8;
    
    logic [WIDTH-1:0] data_in, data_out;

    generate
        if (USE_FAST) begin : fast_path
            assign data_out = data_in << 1;
        end else begin : slow_path
            assign data_out = data_in;
        end
    endgenerate

    generate
        if (WIDTH > 4) begin : wide_check
            logic extra_bit;
            assign extra_bit = |data_in[WIDTH-1:4];
        end
    endgenerate

    initial begin
        data_in = 0;
        #1;

        // Test 1: Generate if true path
        test_count++;
        data_in = 8'h05;
        #1;
        if (data_out == 8'h0A) begin
            pass_count++;
            $display("Test 1 PASS: Fast path = %h", data_out);
        end else begin
            $display("Test 1 FAIL: Path unexpected = %h", data_out);
        end

        // Test 2: Different input
        test_count++;
        data_in = 8'h40;
        #1;
        if (data_out == 8'h80) begin
            pass_count++;
            $display("Test 2 PASS: Shift = %h", data_out);
        end else begin
            $display("Test 2 FAIL: Shift unexpected = %h", data_out);
        end

        // Test 3: Zero input
        test_count++;
        data_in = 8'h00;
        #1;
        if (data_out == 8'h00) begin
            pass_count++;
            $display("Test 3 PASS: Zero = %h", data_out);
        end else begin
            $display("Test 3 FAIL: Zero unexpected = %h", data_out);
        end

        // Test 4: Max input
        test_count++;
        data_in = 8'hFF;
        #1;
        if (data_out == 8'hFE) begin
            pass_count++;
            $display("Test 4 PASS: Max shift = %h", data_out);
        end else begin
            $display("Test 4 FAIL: Max unexpected = %h", data_out);
        end

        // Test 5: The block of the true branch exists (data_in is 8'hFF here)
        test_count++;
        if (wide_check.extra_bit === 1'b1) begin
            pass_count++;
            $display("Test 5 PASS: Wide generate active");
        end else begin
            $display("Test 5 FAIL: Width unexpected");
        end

        $display("=== Generate If Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
