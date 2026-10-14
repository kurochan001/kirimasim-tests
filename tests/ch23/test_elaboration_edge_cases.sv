/*
:name: test_elaboration_edge_cases
:description: Elaboration edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_edge_cases.expected
*/
// IEEE 1800-2023 §23: Elaboration edge cases
// Tests for elaboration-time constructs

module elab_sub #(parameter P = 10) (output logic [7:0] val);
    initial val = P;
endmodule

module test_elaboration_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    localparam WIDTH = 8;
    localparam DEPTH = 4;

    logic [WIDTH-1:0] data;
    logic [WIDTH-1:0] sub_val1, sub_val2;

    // Elaboration-time instantiation
    elab_sub #(.P(42)) u1 (.val(sub_val1));
    elab_sub #(.P(99)) u2 (.val(sub_val2));

    // Generate based on parameter
    generate
        if (WIDTH == 8) begin : gen_8bit
            logic [7:0] extra_reg;
            initial extra_reg = 8'hAA;
        end
    endgenerate

    initial begin
        data = 0;
        #1;

        // Test 1: Parameter value
        test_count++;
        if (WIDTH == 8) begin
            pass_count++;
            $display("Test 1 PASS: WIDTH = %0d", WIDTH);
        end else begin
            $display("Test 1 FAIL: WIDTH unexpected = %0d", WIDTH);
        end

        // Test 2: Second parameter
        test_count++;
        if (DEPTH == 4) begin
            pass_count++;
            $display("Test 2 PASS: DEPTH = %0d", DEPTH);
        end else begin
            $display("Test 2 FAIL: DEPTH unexpected = %0d", DEPTH);
        end

        // Test 3: Submodule with override
        test_count++;
        if (sub_val1 == 42) begin
            pass_count++;
            $display("Test 3 PASS: sub_val1 = %0d", sub_val1);
        end else begin
            $display("Test 3 FAIL: sub unexpected = %0d", sub_val1);
        end

        // Test 4: Second submodule
        test_count++;
        if (sub_val2 == 99) begin
            pass_count++;
            $display("Test 4 PASS: sub_val2 = %0d", sub_val2);
        end else begin
            $display("Test 4 FAIL: sub unexpected = %0d", sub_val2);
        end

        // Test 5: Generated block exists
        test_count++;
        if (gen_8bit.extra_reg == 8'hAA) begin
            pass_count++;
            $display("Test 5 PASS: Gen block val = %h", gen_8bit.extra_reg);
        end else begin
            $display("Test 5 FAIL: Gen unexpected = %h", gen_8bit.extra_reg);
        end

        // Test 6: Use data signal
        test_count++;
        data = 8'h55;
        #1;
        if (data == 8'h55) begin
            pass_count++;
            $display("Test 6 PASS: data = %h", data);
        end else begin
            $display("Test 6 FAIL: data unexpected = %h", data);
        end

        // Test 7: $bits elaboration
        test_count++;
        if ($bits(data) == 8) begin
            pass_count++;
            $display("Test 7 PASS: $bits = %0d", $bits(data));
        end else begin
            $display("Test 7 FAIL: bits unexpected = %0d", $bits(data));
        end

        $display("=== Elaboration Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
