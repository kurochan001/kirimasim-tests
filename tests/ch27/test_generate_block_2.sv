/*
:name: test_generate_block_2
:description: Generate Block Tests
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_block_2.expected
*/
// IEEE 1800-2023 Section 27 - Generate Block Tests
module test_generate_block;
    int pass_count = 0;
    int fail_count = 0;

    parameter WIDTH = 4;
    logic [WIDTH-1:0] data;
    logic [WIDTH-1:0] result;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_loop
            assign result[i] = ~data[i];
        end
    endgenerate

    initial begin
        $display("=== IEEE 1800-2023 Generate Block Tests ===");

        // Test 1: All zeros
        $display("Test 1: All zeros");
        data = 4'b0000;
        #1;
        if (result == 4'b1111) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %b", result); fail_count++; end

        // Test 2: All ones
        $display("Test 2: All ones");
        data = 4'b1111;
        #1;
        if (result == 4'b0000) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %b", result); fail_count++; end

        // Test 3: Alternating
        $display("Test 3: Alternate");
        data = 4'b1010;
        #1;
        if (result == 4'b0101) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %b", result); fail_count++; end

        // Test 4: Reverse alt
        $display("Test 4: Rev alt");
        data = 4'b0101;
        #1;
        if (result == 4'b1010) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %b", result); fail_count++; end

        // Test 5: One hot low
        $display("Test 5: One hot L");
        data = 4'b0001;
        #1;
        if (result == 4'b1110) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %b", result); fail_count++; end

        // Test 6: One hot high
        $display("Test 6: One hot H");
        data = 4'b1000;
        #1;
        if (result == 4'b0111) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %b", result); fail_count++; end

        // Test 7: Half
        $display("Test 7: Half");
        data = 4'b0011;
        #1;
        if (result == 4'b1100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %b", result); fail_count++; end

        // Test 8: Other half
        $display("Test 8: Other half");
        data = 4'b1100;
        #1;
        if (result == 4'b0011) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %b", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
