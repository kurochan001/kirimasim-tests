/*
:name: test_encoder_edge_cases
:description: Encoder edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 12.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_encoder_edge_cases.expected
*/
// IEEE 1800-2023: Encoder edge cases
// Tests for priority encoder constructs

module test_encoder_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [3:0] in;
    logic [1:0] out;
    logic valid;

    // 4:2 priority encoder
    always_comb begin
        valid = 1'b0;
        out = 2'b00;
        if (in[3]) begin out = 2'b11; valid = 1'b1; end
        else if (in[2]) begin out = 2'b10; valid = 1'b1; end
        else if (in[1]) begin out = 2'b01; valid = 1'b1; end
        else if (in[0]) begin out = 2'b00; valid = 1'b1; end
    end

    initial begin
        in = 0;
        #1;

        // Test 1: No input (invalid)
        test_count++;
        in = 4'b0000;
        #1;
        if (valid == 0) begin
            pass_count++;
            $display("Test 1 PASS: No input, valid=%b", valid);
        end else begin
            $display("Test 1 FAIL: unexpected valid=%b", valid);
        end

        // Test 2: Lowest priority
        test_count++;
        in = 4'b0001;
        #1;
        if (out == 2'b00 && valid == 1) begin
            pass_count++;
            $display("Test 2 PASS: in=0001 out=%b", out);
        end else begin
            $display("Test 2 FAIL: unexpected out=%b", out);
        end

        // Test 3: Second priority
        test_count++;
        in = 4'b0010;
        #1;
        if (out == 2'b01 && valid == 1) begin
            pass_count++;
            $display("Test 3 PASS: in=0010 out=%b", out);
        end else begin
            $display("Test 3 FAIL: unexpected out=%b", out);
        end

        // Test 4: Third priority
        test_count++;
        in = 4'b0100;
        #1;
        if (out == 2'b10 && valid == 1) begin
            pass_count++;
            $display("Test 4 PASS: in=0100 out=%b", out);
        end else begin
            $display("Test 4 FAIL: unexpected out=%b", out);
        end

        // Test 5: Highest priority
        test_count++;
        in = 4'b1000;
        #1;
        if (out == 2'b11 && valid == 1) begin
            pass_count++;
            $display("Test 5 PASS: in=1000 out=%b", out);
        end else begin
            $display("Test 5 FAIL: unexpected out=%b", out);
        end

        // Test 6: Priority (high wins)
        test_count++;
        in = 4'b1111;
        #1;
        if (out == 2'b11) begin
            pass_count++;
            $display("Test 6 PASS: in=1111 out=%b (high wins)", out);
        end else begin
            $display("Test 6 FAIL: unexpected out=%b", out);
        end

        // Test 7: Mixed input
        test_count++;
        in = 4'b0101;
        #1;
        if (out == 2'b10) begin
            pass_count++;
            $display("Test 7 PASS: in=0101 out=%b", out);
        end else begin
            $display("Test 7 FAIL: unexpected out=%b", out);
        end

        $display("=== Encoder Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
