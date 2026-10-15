/*
:name: test_seven_seg_edge_cases
:description: A seven-segment decoder from a case statement in always_comb
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_seven_seg_edge_cases.expected
*/
// IEEE 1800-2023: Seven-segment display edge cases
// Tests for 7-segment decoder constructs

module test_seven_seg_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [3:0] digit;
    logic [6:0] segments;  // gfedcba

    // Seven-segment decoder
    always_comb begin
        case (digit)
            4'h0: segments = 7'b0111111;  // 0
            4'h1: segments = 7'b0000110;  // 1
            4'h2: segments = 7'b1011011;  // 2
            4'h3: segments = 7'b1001111;  // 3
            4'h4: segments = 7'b1100110;  // 4
            4'h5: segments = 7'b1101101;  // 5
            4'h6: segments = 7'b1111101;  // 6
            4'h7: segments = 7'b0000111;  // 7
            4'h8: segments = 7'b1111111;  // 8
            4'h9: segments = 7'b1101111;  // 9
            4'hA: segments = 7'b1110111;  // A
            4'hB: segments = 7'b1111100;  // b
            4'hC: segments = 7'b0111001;  // C
            4'hD: segments = 7'b1011110;  // d
            4'hE: segments = 7'b1111001;  // E
            4'hF: segments = 7'b1110001;  // F
            default: segments = 7'b0000000;
        endcase
    end

    initial begin
        // Test 1: Digit 0
        test_count++;
        digit = 4'h0;
        #1;
        if (segments == 7'b0111111) begin
            pass_count++;
            $display("Test 1 PASS: 0 -> %b", segments);
        end else begin
            $display("Test 1 FAIL: unexpected segments=%b", segments);
        end

        // Test 2: Digit 1
        test_count++;
        digit = 4'h1;
        #1;
        if (segments == 7'b0000110) begin
            pass_count++;
            $display("Test 2 PASS: 1 -> %b", segments);
        end else begin
            $display("Test 2 FAIL: unexpected segments=%b", segments);
        end

        // Test 3: Digit 8 (all segments)
        test_count++;
        digit = 4'h8;
        #1;
        if (segments == 7'b1111111) begin
            pass_count++;
            $display("Test 3 PASS: 8 -> %b", segments);
        end else begin
            $display("Test 3 FAIL: unexpected segments=%b", segments);
        end

        // Test 4: Hex digit A
        test_count++;
        digit = 4'hA;
        #1;
        if (segments == 7'b1110111) begin
            pass_count++;
            $display("Test 4 PASS: A -> %b", segments);
        end else begin
            $display("Test 4 FAIL: A -> %b", segments);
        end

        // Test 5: Hex digit F
        test_count++;
        digit = 4'hF;
        #1;
        if (segments == 7'b1110001) begin
            pass_count++;
            $display("Test 5 PASS: F -> %b", segments);
        end else begin
            $display("Test 5 FAIL: F -> %b", segments);
        end

        // Test 6: All digits
        test_count++;
        begin
            static logic [6:0] exp_seg[16] = '{
                7'b0111111, 7'b0000110, 7'b1011011, 7'b1001111,
                7'b1100110, 7'b1101101, 7'b1111101, 7'b0000111,
                7'b1111111, 7'b1101111, 7'b1110111, 7'b1111100,
                7'b0111001, 7'b1011110, 7'b1111001, 7'b1110001};
            static int bad = 0;
            for (int i = 0; i < 16; i++) begin
                digit = i[3:0];
                #1;
                if (segments !== exp_seg[i]) bad++;
            end
            if (bad == 0) begin
                pass_count++;
                $display("Test 6 PASS: All digits tested");
            end else begin
                $display("Test 6 FAIL: %0d digits wrong", bad);
            end
        end

        $display("=== Seven-Segment Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
