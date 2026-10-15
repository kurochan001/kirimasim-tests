/*
:name: test_bit_type_edge_cases
:description: Bit type edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 11.4.8 11.4.10 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_type_edge_cases.expected
*/
// IEEE 1800-2023 §6.11.1: Bit type edge cases
// Tests for 2-state bit type

module test_bit_type_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    bit b;
    bit [7:0] bvec;
    bit [15:0] bword;
    bit signed [7:0] sb;

    initial begin
        // Test 1: Bit default
        test_count++;
        if (b == 0) begin
            pass_count++;
            $display("Test 1 PASS: Default bit = %b", b);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %b", b);
        end

        // Test 2: Bit assignment
        test_count++;
        b = 1;
        if (b == 1) begin
            pass_count++;
            $display("Test 2 PASS: Assign = %b", b);
        end else begin
            $display("Test 2 FAIL: Assign unexpected = %b", b);
        end

        // Test 3: Bit vector
        test_count++;
        bvec = 8'hAA;
        if (bvec == 8'hAA) begin
            pass_count++;
            $display("Test 3 PASS: Vector = %h", bvec);
        end else begin
            $display("Test 3 FAIL: Vec unexpected = %h", bvec);
        end

        // Test 4: Bit word
        test_count++;
        bword = 16'h1234;
        if (bword == 16'h1234) begin
            pass_count++;
            $display("Test 4 PASS: Word = %h", bword);
        end else begin
            $display("Test 4 FAIL: Word unexpected = %h", bword);
        end

        // Test 5: Signed bit
        test_count++;
        sb = -8'sd10;
        if (sb < 0) begin
            pass_count++;
            $display("Test 5 PASS: Signed = %0d", sb);
        end else begin
            $display("Test 5 FAIL: Signed unexpected = %0d", sb);
        end

        // Test 6: Bit operations
        test_count++;
        bvec = 8'hF0;
        begin
            static bit [7:0] and_result;
            // Assigned here so the result does not depend on the order of static initializers.
            and_result = bvec & 8'h0F;
            if (and_result == 8'h00) begin
                pass_count++;
                $display("Test 6 PASS: AND = %h", and_result);
            end else begin
                $display("Test 6 FAIL: AND unexpected = %h", and_result);
            end
        end

        // Test 7: Bit OR
        test_count++;
        begin
            static bit [7:0] or_result;
            // Assigned here so the result does not depend on the order of static initializers.
            or_result = bvec | 8'h0F;
            if (or_result == 8'hFF) begin
                pass_count++;
                $display("Test 7 PASS: OR = %h", or_result);
            end else begin
                $display("Test 7 FAIL: OR unexpected = %h", or_result);
            end
        end

        // Test 8: Bit XOR
        test_count++;
        bvec = 8'hAA;
        begin
            static bit [7:0] xor_result;
            // Assigned here so the result does not depend on the order of static initializers.
            xor_result = bvec ^ 8'hFF;
            if (xor_result == 8'h55) begin
                pass_count++;
                $display("Test 8 PASS: XOR = %h", xor_result);
            end else begin
                $display("Test 8 FAIL: XOR unexpected = %h", xor_result);
            end
        end

        // Test 9: Bit shift
        test_count++;
        bvec = 8'h01;
        begin
            static bit [7:0] shifted;
            // Assigned here so the result does not depend on the order of static initializers.
            shifted = bvec << 4;
            if (shifted == 8'h10) begin
                pass_count++;
                $display("Test 9 PASS: Shift = %h", shifted);
            end else begin
                $display("Test 9 FAIL: Shift unexpected = %h", shifted);
            end
        end

        // Test 10: Reduction
        test_count++;
        bvec = 8'hFF;
        begin
            static bit reduced;
            // Assigned here so the result does not depend on the order of static initializers.
            reduced = &bvec;
            if (reduced == 1) begin
                pass_count++;
                $display("Test 10 PASS: Reduction = %b", reduced);
            end else begin
                $display("Test 10 FAIL: Red unexpected = %b", reduced);
            end
        end

        $display("=== Bit Type Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
