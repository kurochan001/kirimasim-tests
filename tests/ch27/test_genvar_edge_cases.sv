/*
:name: test_genvar_edge_cases
:description: Genvar edge cases
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_genvar_edge_cases.expected
*/
// IEEE 1800-2023 §27.4: Genvar edge cases
// Tests for genvar declarations

module test_genvar_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    localparam N = 4;
    logic [N-1:0] a, b, c;

    genvar i;

    // Generate array of ANDs
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_and
            assign c[i] = a[i] & b[i];
        end
    endgenerate

    initial begin
        a = 0;
        b = 0;
        #1;

        // Test 1: Generated AND with zeros
        test_count++;
        a = 4'h0;
        b = 4'hF;
        #1;
        if (c == 4'h0) begin
            pass_count++;
            $display("Test 1 PASS: AND zeros = %h", c);
        end else begin
            $display("Test 1 FAIL: AND unexpected = %h", c);
        end

        // Test 2: Generated AND with ones
        test_count++;
        a = 4'hF;
        b = 4'hF;
        #1;
        if (c == 4'hF) begin
            pass_count++;
            $display("Test 2 PASS: AND ones = %h", c);
        end else begin
            $display("Test 2 FAIL: AND unexpected = %h", c);
        end

        // Test 3: Pattern match
        test_count++;
        a = 4'hA;
        b = 4'hC;
        #1;
        if (c == 4'h8) begin
            pass_count++;
            $display("Test 3 PASS: A&C = %h", c);
        end else begin
            $display("Test 3 FAIL: Pattern unexpected = %h", c);
        end

        // Test 4: Alternating pattern
        test_count++;
        a = 4'h5;
        b = 4'hA;
        #1;
        if (c == 4'h0) begin
            pass_count++;
            $display("Test 4 PASS: 5&A = %h", c);
        end else begin
            $display("Test 4 FAIL: Alt unexpected = %h", c);
        end

        // Test 5: Same value
        test_count++;
        a = 4'h9;
        b = 4'h9;
        #1;
        if (c == 4'h9) begin
            pass_count++;
            $display("Test 5 PASS: 9&9 = %h", c);
        end else begin
            $display("Test 5 FAIL: Same unexpected = %h", c);
        end

        // Test 6: Single bit
        test_count++;
        a = 4'h1;
        b = 4'h1;
        #1;
        if (c == 4'h1) begin
            pass_count++;
            $display("Test 6 PASS: 1&1 = %h", c);
        end else begin
            $display("Test 6 FAIL: Single unexpected = %h", c);
        end

        // Test 7: Top bit
        test_count++;
        a = 4'h8;
        b = 4'h8;
        #1;
        if (c == 4'h8) begin
            pass_count++;
            $display("Test 7 PASS: 8&8 = %h", c);
        end else begin
            $display("Test 7 FAIL: Top unexpected = %h", c);
        end

        $display("=== Genvar Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
