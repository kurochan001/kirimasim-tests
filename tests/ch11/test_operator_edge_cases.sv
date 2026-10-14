/*
:name: test_operator_edge_cases
:description: Operator edge cases test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10 11.4.3 11.4.9 11.4.11 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_edge_cases.expected
*/
// IEEE 1800-2023: Operator edge cases test
// Tests various operator edge cases

module test_operator_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    // Variables for testing
    logic [31:0] a, b, c;
    logic [63:0] wide;
    int signed_a, signed_b;
    real r1, r2;

    initial begin
        // Test 1: Shift by 0
        test_count++;
        a = 32'hDEADBEEF;
        b = a << 0;
        c = a >> 0;
        if (b == a && c == a) begin
            pass_count++;
            $display("Test 1 PASS: shift by 0 preserves value");
        end else begin
            $display("Test 1 FAIL: shift by 0 issue");
        end

        // Test 2: Shift by width (undefined, but test behavior)
        test_count++;
        a = 32'hFFFFFFFF;
        b = a << 32;
        if (b == 0) begin
            pass_count++;
            $display("Test 2 PASS: shift by width produces 0");
        end else begin
            $display("Test 2 FAIL: shift by width issue (got %h)", b);
        end

        // Test 3: Division by 1
        test_count++;
        a = 32'd100;
        b = a / 1;
        if (b == 100) begin
            pass_count++;
            $display("Test 3 PASS: division by 1");
        end else begin
            $display("Test 3 FAIL: division by 1 issue");
        end

        // Test 4: Modulo by 1
        test_count++;
        a = 32'd100;
        b = a % 1;
        if (b == 0) begin
            pass_count++;
            $display("Test 4 PASS: modulo by 1 is 0");
        end else begin
            $display("Test 4 FAIL: modulo by 1 issue");
        end

        // Test 5: Signed negative division
        test_count++;
        signed_a = -10;
        signed_b = signed_a / 3;
        if (signed_b == -3) begin
            pass_count++;
            $display("Test 5 PASS: signed negative division");
        end else begin
            $display("Test 5 FAIL: signed division issue (got %0d)", signed_b);
        end

        // Test 6: Bitwise on all zeros
        test_count++;
        a = 32'h0;
        b = ~a;
        if (b == 32'hFFFFFFFF) begin
            pass_count++;
            $display("Test 6 PASS: bitwise NOT of zeros");
        end else begin
            $display("Test 6 FAIL: bitwise NOT issue");
        end

        // Test 7: Reduction operators on single bit
        test_count++;
        begin
            static logic single_bit = 1'b1;
            if (&single_bit == 1 && |single_bit == 1 && ^single_bit == 1) begin
                pass_count++;
                $display("Test 7 PASS: reduction on single bit");
            end else begin
                $display("Test 7 FAIL: reduction issue");
            end
        end

        // Test 8: Ternary with same true/false
        test_count++;
        a = 32'h42;
        b = (1'b1) ? a : a;
        c = (1'b0) ? a : a;
        if (b == a && c == a) begin
            pass_count++;
            $display("Test 8 PASS: ternary with same values");
        end else begin
            $display("Test 8 FAIL: ternary issue");
        end

        // Test 9: Concatenation of zeros
        test_count++;
        wide = {32'h0, 32'h0};
        if (wide == 64'h0) begin
            pass_count++;
            $display("Test 9 PASS: concatenation of zeros");
        end else begin
            $display("Test 9 FAIL: concatenation issue");
        end

        // Test 10: Replication of 0
        test_count++;
        a = {4{8'h00}};
        if (a == 32'h0) begin
            pass_count++;
            $display("Test 10 PASS: replication of zeros");
        end else begin
            $display("Test 10 FAIL: replication issue");
        end

        $display("=== Operator Edge Cases Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
