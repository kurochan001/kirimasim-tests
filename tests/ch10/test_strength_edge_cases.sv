/*
:name: test_strength_edge_cases
:description: Strength edge cases
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.4 28.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_strength_edge_cases.expected
*/
// IEEE 1800-2023 §10.3.4 and §28.11: Drive strength edge cases
// Tests for signal strength modeling

module test_strength_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire w1, w2;
    logic d1, d2;

    // Different strength drives
    assign (strong1, strong0) w1 = d1;
    assign (weak1, weak0) w2 = d2;

    initial begin
        d1 = 0;
        d2 = 0;
        #1;

        // Test 1: Strong drive low
        test_count++;
        if (w1 == 0) begin
            pass_count++;
            $display("Test 1 PASS: Strong low = %b", w1);
        end else begin
            $display("Test 1 FAIL: Strong unexpected = %b", w1);
        end

        // Test 2: Strong drive high
        test_count++;
        d1 = 1;
        #1;
        if (w1 == 1) begin
            pass_count++;
            $display("Test 2 PASS: Strong high = %b", w1);
        end else begin
            $display("Test 2 FAIL: Strong unexpected = %b", w1);
        end

        // Test 3: Weak drive low
        test_count++;
        d2 = 0;
        #1;
        if (w2 == 0) begin
            pass_count++;
            $display("Test 3 PASS: Weak low = %b", w2);
        end else begin
            $display("Test 3 FAIL: Weak unexpected = %b", w2);
        end

        // Test 4: Weak drive high
        test_count++;
        d2 = 1;
        #1;
        if (w2 == 1) begin
            pass_count++;
            $display("Test 4 PASS: Weak high = %b", w2);
        end else begin
            $display("Test 4 FAIL: Weak unexpected = %b", w2);
        end

        // Test 5: Toggle strong
        test_count++;
        d1 = 0; #1;
        d1 = 1; #1;
        d1 = 0; #1;
        pass_count++;
        $display("Test 5 PASS: Toggle strong = %b", w1);

        // Test 6: Toggle weak
        test_count++;
        d2 = 0; #1;
        d2 = 1; #1;
        d2 = 0; #1;
        pass_count++;
        $display("Test 6 PASS: Toggle weak = %b", w2);

        // Test 7: Both low
        test_count++;
        d1 = 0;
        d2 = 0;
        #1;
        if (w1 == 0 && w2 == 0) begin
            pass_count++;
            $display("Test 7 PASS: Both low");
        end else begin
            $display("Test 7 FAIL: Both unexpected");
        end

        // Test 8: Both high
        test_count++;
        d1 = 1;
        d2 = 1;
        #1;
        if (w1 == 1 && w2 == 1) begin
            pass_count++;
            $display("Test 8 PASS: Both high");
        end else begin
            $display("Test 8 FAIL: Both unexpected");
        end

        $display("=== Strength Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
