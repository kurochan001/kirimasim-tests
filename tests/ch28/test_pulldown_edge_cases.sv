/*
:name: test_pulldown_edge_cases
:description: Pulldown edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.10 28.12
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pulldown_edge_cases.expected
*/
// IEEE 1800-2023 §28.7: Pulldown edge cases
// Tests for pulldown primitive

module test_pulldown_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire w1, w2;
    logic driver1, driver2;

    pulldown (w1);
    pulldown (w2);

    assign w1 = driver1 ? 1'b1 : 1'bz;
    assign w2 = driver2 ? 1'b1 : 1'bz;

    initial begin
        driver1 = 0;
        driver2 = 0;
        #1;

        // Test 1: Pulldown default (low)
        test_count++;
        if (w1 == 0) begin
            pass_count++;
            $display("Test 1 PASS: Pulldown = %b", w1);
        end else begin
            $display("Test 1 FAIL: Pulldown unexpected = %b", w1);
        end

        // Test 2: Second pulldown
        test_count++;
        if (w2 == 0) begin
            pass_count++;
            $display("Test 2 PASS: Pulldown2 = %b", w2);
        end else begin
            $display("Test 2 FAIL: Pulldown2 unexpected = %b", w2);
        end

        // Test 3: Drive high overrides pulldown
        test_count++;
        driver1 = 1;
        #1;
        if (w1 == 1) begin
            pass_count++;
            $display("Test 3 PASS: Driven high = %b", w1);
        end else begin
            $display("Test 3 FAIL: Drive unexpected = %b", w1);
        end

        // Test 4: Release returns to pulldown
        test_count++;
        driver1 = 0;
        #1;
        if (w1 == 0) begin
            pass_count++;
            $display("Test 4 PASS: Released = %b", w1);
        end else begin
            $display("Test 4 FAIL: Release unexpected = %b", w1);
        end

        // Test 5: Both wires pulled down
        test_count++;
        if (w1 == 0 && w2 == 0) begin
            pass_count++;
            $display("Test 5 PASS: Both low");
        end else begin
            $display("Test 5 FAIL: Both unexpected");
        end

        // Test 6: Drive w2 high
        test_count++;
        driver2 = 1;
        #1;
        if (w2 == 1) begin
            pass_count++;
            $display("Test 6 PASS: w2 driven = %b", w2);
        end else begin
            $display("Test 6 FAIL: w2 unexpected = %b", w2);
        end

        // Test 7: Both driven high
        test_count++;
        driver1 = 1;
        #1;
        if (w1 == 1 && w2 == 1) begin
            pass_count++;
            $display("Test 7 PASS: Both high");
        end else begin
            $display("Test 7 FAIL: Both unexpected");
        end

        // Test 8: Release both
        test_count++;
        driver1 = 0;
        driver2 = 0;
        #1;
        if (w1 == 0 && w2 == 0) begin
            pass_count++;
            $display("Test 8 PASS: Both released");
        end else begin
            $display("Test 8 FAIL: Release unexpected");
        end

        $display("=== Pulldown Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
