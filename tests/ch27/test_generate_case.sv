/*
:name: test_generate_case
:description: Generate Case Tests
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_case.expected
*/
// IEEE 1800-2023 Section 27.4 - Generate Case Tests
module test_generate_case;
    int pass_count = 0;
    int fail_count = 0;
    
    parameter MODE = 2;
    logic [7:0] result;

    generate
        case (MODE)
            0: begin : mode0
                assign result = 8'h00;
            end
            1: begin : mode1
                assign result = 8'h11;
            end
            2: begin : mode2
                assign result = 8'h22;
            end
            default: begin : modedef
                assign result = 8'hFF;
            end
        endcase
    endgenerate

    initial begin
        $display("=== IEEE 1800-2023 Generate Case Tests ===");

        // Test 1: MODE value
        $display("Test 1: MODE value");
        if (MODE == 2) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", MODE); fail_count++; end

        // Test 2: Result check
        $display("Test 2: Result");
        #1;
        if (result == 8'h22) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", result); fail_count++; end

        // Test 3: Not mode0
        $display("Test 3: Not mode0");
        if (result != 8'h00) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Not mode1
        $display("Test 4: Not mode1");
        if (result != 8'h11) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Not default
        $display("Test 5: Not default");
        if (result != 8'hFF) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: High nibble
        $display("Test 6: High nibble");
        if (result[7:4] == 4'h2) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", result[7:4]); fail_count++; end

        // Test 7: Low nibble
        $display("Test 7: Low nibble");
        if (result[3:0] == 4'h2) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", result[3:0]); fail_count++; end

        // Test 8: Full match
        $display("Test 8: Full match");
        if (result === 8'h22) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
