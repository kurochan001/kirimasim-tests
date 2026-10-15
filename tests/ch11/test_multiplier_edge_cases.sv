/*
:name: test_multiplier_edge_cases
:description: Unsigned and signed products in a wider context
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multiplier_edge_cases.expected
*/
// IEEE 1800-2023: Multiplier edge cases
// Tests for multiplier constructs

module test_multiplier_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b;
    logic [15:0] product;
    logic signed [7:0] sa, sb;
    logic signed [15:0] s_product;

    // Unsigned multiplier
    assign product = a * b;

    // Signed multiplier
    assign s_product = sa * sb;

    initial begin
        // Test 1: 0 * anything
        test_count++;
        a = 0; b = 8'hFF;
        #1;
        if (product == 0) begin
            pass_count++;
            $display("Test 1 PASS: 0*FF=%0d", product);
        end else begin
            $display("Test 1 FAIL: unexpected product=%0d", product);
        end

        // Test 2: 1 * value
        test_count++;
        a = 1; b = 8'h55;
        #1;
        if (product == 8'h55) begin
            pass_count++;
            $display("Test 2 PASS: 1*55=%h", product);
        end else begin
            $display("Test 2 FAIL: unexpected product=%h", product);
        end

        // Test 3: Max * Max
        test_count++;
        a = 8'hFF; b = 8'hFF;
        #1;
        if (product == 16'hFE01) begin
            pass_count++;
            $display("Test 3 PASS: FF*FF=%h", product);
        end else begin
            $display("Test 3 FAIL: unexpected product=%h", product);
        end

        // Test 4: Power of 2 multiply
        test_count++;
        a = 8'h10; b = 8'h10;
        #1;
        if (product == 16'h0100) begin
            pass_count++;
            $display("Test 4 PASS: 10*10=%h", product);
        end else begin
            $display("Test 4 FAIL: unexpected product=%h", product);
        end

        // Test 5: Signed positive * positive
        test_count++;
        sa = 10; sb = 5;
        #1;
        if (s_product == 50) begin
            pass_count++;
            $display("Test 5 PASS: signed 10*5=%0d", s_product);
        end else begin
            $display("Test 5 FAIL: unexpected s_product=%0d", s_product);
        end

        // Test 6: Signed negative * positive
        test_count++;
        sa = -10; sb = 5;
        #1;
        if (s_product == -50) begin
            pass_count++;
            $display("Test 6 PASS: signed -10*5=%0d", s_product);
        end else begin
            $display("Test 6 FAIL: unexpected s_product=%0d", s_product);
        end

        // Test 7: Signed negative * negative
        test_count++;
        sa = -10; sb = -5;
        #1;
        if (s_product == 50) begin
            pass_count++;
            $display("Test 7 PASS: signed -10*-5=%0d", s_product);
        end else begin
            $display("Test 7 FAIL: unexpected s_product=%0d", s_product);
        end

        $display("=== Multiplier Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
