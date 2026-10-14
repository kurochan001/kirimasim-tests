/*
:name: test_always_latch
:description: Always_latch Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_latch.expected
*/
// IEEE 1800-2023 Section 9.2.2.3 - Always_latch Tests
module test_always_latch;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] data_in, latch_out;
    logic enable;

    always_latch begin
        if (enable)
            latch_out = data_in;
    end

    initial begin
        $display("=== IEEE 1800-2023 Always_latch Tests ===");

        // Test 1-8
        $display("Test 1: Enable high");
        enable = 1;
        data_in = 8'h55;
        #1;
        if (latch_out == 8'h55) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", latch_out); fail_count++; end

        $display("Test 2: Change data");
        data_in = 8'hAA;
        #1;
        if (latch_out == 8'hAA) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", latch_out); fail_count++; end

        $display("Test 3: Disable");
        enable = 0;
        data_in = 8'hFF;
        #1;
        if (latch_out == 8'hAA) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", latch_out); fail_count++; end

        $display("Test 4: Re-enable");
        enable = 1;
        #1;
        if (latch_out == 8'hFF) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", latch_out); fail_count++; end

        $display("Test 5: Zero");
        data_in = 8'h00;
        #1;
        if (latch_out == 8'h00) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", latch_out); fail_count++; end

        $display("Test 6: Max");
        data_in = 8'hFF;
        #1;
        if (latch_out == 8'hFF) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", latch_out); fail_count++; end

        $display("Test 7: Pattern");
        data_in = 8'b10101010;
        #1;
        if (latch_out == 8'hAA) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", latch_out); fail_count++; end

        $display("Test 8: Final");
        data_in = 8'h12;
        #1;
        if (latch_out == 8'h12) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", latch_out); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
