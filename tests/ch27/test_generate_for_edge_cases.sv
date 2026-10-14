/*
:name: test_generate_for_edge_cases
:description: Generate for edge cases
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_for_edge_cases.expected
*/
// IEEE 1800-2023 §27.4: Generate for edge cases
// Tests for loop generate blocks

module test_generate_for_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    parameter N = 4;
    
    logic [N-1:0] in_bits;
    logic [N-1:0] out_bits;
    logic [N-1:0] delayed;

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : bit_proc
            assign out_bits[i] = ~in_bits[i];
        end
    endgenerate

    initial begin
        in_bits = 0;
        #1;

        // Test 1: Invert zeros
        test_count++;
        in_bits = 4'b0000;
        #1;
        if (out_bits == 4'b1111) begin
            pass_count++;
            $display("Test 1 PASS: Invert 0 = %b", out_bits);
        end else begin
            $display("Test 1 FAIL: Inv0 unexpected = %b", out_bits);
        end

        // Test 2: Invert ones
        test_count++;
        in_bits = 4'b1111;
        #1;
        if (out_bits == 4'b0000) begin
            pass_count++;
            $display("Test 2 PASS: Invert 1 = %b", out_bits);
        end else begin
            $display("Test 2 FAIL: Inv1 unexpected = %b", out_bits);
        end

        // Test 3: Mixed pattern
        test_count++;
        in_bits = 4'b1010;
        #1;
        if (out_bits == 4'b0101) begin
            pass_count++;
            $display("Test 3 PASS: Mixed = %b", out_bits);
        end else begin
            $display("Test 3 FAIL: Mixed unexpected = %b", out_bits);
        end

        // Test 4: Single bit
        test_count++;
        in_bits = 4'b0001;
        #1;
        if (out_bits == 4'b1110) begin
            pass_count++;
            $display("Test 4 PASS: Single = %b", out_bits);
        end else begin
            $display("Test 4 FAIL: Single unexpected = %b", out_bits);
        end

        // Test 5: Sequential test
        test_count++;
        for (int j = 0; j < N; j++) begin
            in_bits = 1 << j;
            #1;
        end
        pass_count++;
        $display("Test 5 PASS: Sequential test");

        $display("=== Generate For Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
