/*
:name: test_wor_edge_cases
:description: wor nets resolving two drivers
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wor_edge_cases.expected
*/
// IEEE 1800-2023 §6.6.3: Wor (wired-OR) edge cases
// Tests for wired-OR net type

module test_wor_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wor w;
    wor [3:0] wvec;

    logic d1, d2;
    logic [3:0] dv1, dv2;

    assign w = d1;
    assign w = d2;
    assign wvec = dv1;
    assign wvec = dv2;

    initial begin
        // Test 1: Both drivers high (1 OR 1 = 1)
        test_count++;
        d1 = 1;
        d2 = 1;
        #1;
        if (w == 1) begin
            pass_count++;
            $display("Test 1 PASS: 1 OR 1 = %b", w);
        end else begin
            $display("Test 1 FAIL: OR unexpected = %b", w);
        end

        // Test 2: One driver high (1 OR 0 = 1)
        test_count++;
        d1 = 1;
        d2 = 0;
        #1;
        if (w == 1) begin
            pass_count++;
            $display("Test 2 PASS: 1 OR 0 = %b", w);
        end else begin
            $display("Test 2 FAIL: OR unexpected = %b", w);
        end

        // Test 3: Both drivers low (0 OR 0 = 0)
        test_count++;
        d1 = 0;
        d2 = 0;
        #1;
        if (w == 0) begin
            pass_count++;
            $display("Test 3 PASS: 0 OR 0 = %b", w);
        end else begin
            $display("Test 3 FAIL: OR unexpected = %b", w);
        end

        // Test 4: Vector both high
        test_count++;
        dv1 = 4'hF;
        dv2 = 4'hF;
        #1;
        if (wvec == 4'hF) begin
            pass_count++;
            $display("Test 4 PASS: F OR F = %h", wvec);
        end else begin
            $display("Test 4 FAIL: Vec unexpected = %h", wvec);
        end

        // Test 5: Vector OR
        test_count++;
        dv1 = 4'h5;
        dv2 = 4'hA;
        #1;
        if (wvec == 4'hF) begin
            pass_count++;
            $display("Test 5 PASS: 5 OR A = %h", wvec);
        end else begin
            $display("Test 5 FAIL: Vec unexpected = %h", wvec);
        end

        // Test 6: Vector both zero
        test_count++;
        dv1 = 4'h0;
        dv2 = 4'h0;
        #1;
        if (wvec == 4'h0) begin
            pass_count++;
            $display("Test 6 PASS: 0 OR 0 = %h", wvec);
        end else begin
            $display("Test 6 FAIL: Vec unexpected = %h", wvec);
        end

        // Test 7: Different patterns
        test_count++;
        dv1 = 4'h1;
        dv2 = 4'h2;
        #1;
        if (wvec == 4'h3) begin
            pass_count++;
            $display("Test 7 PASS: 1 OR 2 = %h", wvec);
        end else begin
            $display("Test 7 FAIL: Vec unexpected = %h", wvec);
        end

        // Test 8: Bit select
        test_count++;
        if (wvec[0] == 1 && wvec[1] == 1) begin
            pass_count++;
            $display("Test 8 PASS: Bit[1:0] = %b%b", wvec[1], wvec[0]);
        end else begin
            $display("Test 8 FAIL: Bit unexpected");
        end

        $display("=== Wor Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
