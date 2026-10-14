/*
:name: test_decoder_edge_cases
:description: Decoder edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_decoder_edge_cases.expected
*/
// IEEE 1800-2023: Decoder edge cases
// Tests for decoder constructs

module test_decoder_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [1:0] sel;
    logic [3:0] out;

    // 2:4 decoder
    always_comb begin
        out = 4'b0000;
        out[sel] = 1'b1;
    end

    initial begin
        sel = 0;
        #1;

        // Test 1: Decode 00
        test_count++;
        sel = 2'b00;
        #1;
        if (out == 4'b0001) begin
            pass_count++;
            $display("Test 1 PASS: sel=00 out=%b", out);
        end else begin
            $display("Test 1 FAIL: unexpected = %b", out);
        end

        // Test 2: Decode 01
        test_count++;
        sel = 2'b01;
        #1;
        if (out == 4'b0010) begin
            pass_count++;
            $display("Test 2 PASS: sel=01 out=%b", out);
        end else begin
            $display("Test 2 FAIL: unexpected = %b", out);
        end

        // Test 3: Decode 10
        test_count++;
        sel = 2'b10;
        #1;
        if (out == 4'b0100) begin
            pass_count++;
            $display("Test 3 PASS: sel=10 out=%b", out);
        end else begin
            $display("Test 3 FAIL: unexpected = %b", out);
        end

        // Test 4: Decode 11
        test_count++;
        sel = 2'b11;
        #1;
        if (out == 4'b1000) begin
            pass_count++;
            $display("Test 4 PASS: sel=11 out=%b", out);
        end else begin
            $display("Test 4 FAIL: unexpected = %b", out);
        end

        // Test 5: One-hot check
        test_count++;
        if ($countones(out) == 1) begin
            pass_count++;
            $display("Test 5 PASS: One-hot count=%0d", $countones(out));
        end else begin
            $display("Test 5 FAIL: unexpected count=%0d", $countones(out));
        end

        // Test 6: Cycle through all
        test_count++;
        for (int i = 0; i < 4; i++) begin
            sel = i[1:0];
            #1;
        end
        pass_count++;
        $display("Test 6 PASS: Cycle complete");

        // Test 7: Back to 00
        test_count++;
        sel = 2'b00;
        #1;
        if (out[0] == 1) begin
            pass_count++;
            $display("Test 7 PASS: Back to 00");
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Decoder Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
