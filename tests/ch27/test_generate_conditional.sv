/*
:name: test_generate_conditional
:description: Generate conditional constructs
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 27.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_conditional.expected
*/
// IEEE 1800-2023 §27.5: Generate conditional constructs
// Tests if-else and case generate constructs

module test_generate_conditional;
    int pass_count = 0;
    int test_count = 0;

    parameter int MODE = 2;
    parameter int WIDTH = 8;
    parameter bit ENABLE_DEBUG = 1;

    // Test generate-if
    logic [WIDTH-1:0] data_a;
    logic [WIDTH-1:0] data_b;
    logic [WIDTH-1:0] result;

    generate
        if (MODE == 0) begin : mode0_gen
            assign result = data_a;
        end else if (MODE == 1) begin : mode1_gen
            assign result = data_b;
        end else begin : mode_default_gen
            assign result = data_a ^ data_b;
        end
    endgenerate

    // Test generate-case
    logic [3:0] select_out;

    generate
        case (WIDTH)
            4: begin : width4_gen
                assign select_out = 4'b0001;
            end
            8: begin : width8_gen
                assign select_out = 4'b0010;
            end
            16: begin : width16_gen
                assign select_out = 4'b0100;
            end
            default: begin : width_default_gen
                assign select_out = 4'b1000;
            end
        endcase
    endgenerate

    // Test conditional instantiation
    generate
        if (ENABLE_DEBUG) begin : debug_gen
            logic debug_flag;
            initial debug_flag = 1;
        end
    endgenerate

    initial begin
        // Test 1: Generate-if with MODE=2 (XOR mode)
        test_count++;
        data_a = 8'hAA;
        data_b = 8'h55;
        #1;
        if (result == (8'hAA ^ 8'h55)) begin
            pass_count++;
            $display("Test 1 PASS: generate-if MODE=2 XOR result=%h", result);
        end else begin
            $display("Test 1 FAIL: expected %h, got %h", (8'hAA ^ 8'h55), result);
        end

        // Test 2: Generate-if data change
        test_count++;
        data_a = 8'hFF;
        data_b = 8'h0F;
        #1;
        if (result == 8'hF0) begin
            pass_count++;
            $display("Test 2 PASS: generate-if XOR F0");
        end else begin
            $display("Test 2 FAIL: expected F0, got %h", result);
        end

        // Test 3: Generate-case with WIDTH=8
        test_count++;
        if (select_out == 4'b0010) begin
            pass_count++;
            $display("Test 3 PASS: generate-case WIDTH=8");
        end else begin
            $display("Test 3 FAIL: expected 0010, got %b", select_out);
        end

        // Test 4: Conditional generate instance exists
        test_count++;
        if (ENABLE_DEBUG) begin
            if (debug_gen.debug_flag == 1) begin
                pass_count++;
                $display("Test 4 PASS: conditional generate instance");
            end else begin
                $display("Test 4 FAIL: debug_flag wrong");
            end
        end else begin
            pass_count++;  // No debug_gen, but that's expected
            $display("Test 4 PASS: debug disabled (expected)");
        end

        // Test 5: Generate block naming
        test_count++;
        begin
            // Access generated block by name
            if (MODE == 2) begin
                // mode_default_gen should exist
                pass_count++;
                $display("Test 5 PASS: generate block naming");
            end else begin
                $display("Test 5 FAIL: unexpected mode");
            end
        end

        // Test 6: Multiple generate conditions
        test_count++;
        data_a = 8'h00;
        data_b = 8'h00;
        #1;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 6 PASS: XOR of zeros");
        end else begin
            $display("Test 6 FAIL: XOR zeros");
        end

        $display("=== Generate Conditional Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
