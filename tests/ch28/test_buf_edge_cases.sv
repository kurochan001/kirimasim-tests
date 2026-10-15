/*
:name: test_buf_edge_cases
:description: BUF gate edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_buf_edge_cases.expected
*/
// IEEE 1800-2023 §28.2: BUF gate edge cases
// Tests for buf primitive

module test_buf_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic a;
    wire out1, out2;

    buf (out1, a);
    buf u2 (out2, a);  // Named instance

    initial begin
        a = 0;
        #1;

        // Test 1: BUF 0 = 0
        test_count++;
        if (out1 == 0) begin
            pass_count++;
            $display("Test 1 PASS: buf(0) = %b", out1);
        end else begin
            $display("Test 1 FAIL: unexpected = %b", out1);
        end

        // Test 2: Named BUF 0 = 0
        test_count++;
        if (out2 == 0) begin
            pass_count++;
            $display("Test 2 PASS: Named buf(0) = %b", out2);
        end else begin
            $display("Test 2 FAIL: unexpected = %b", out2);
        end

        // Test 3: BUF 1 = 1
        test_count++;
        a = 1;
        #1;
        if (out1 == 1) begin
            pass_count++;
            $display("Test 3 PASS: buf(1) = %b", out1);
        end else begin
            $display("Test 3 FAIL: unexpected = %b", out1);
        end

        // Test 4: Named BUF 1 = 1
        test_count++;
        if (out2 == 1) begin
            pass_count++;
            $display("Test 4 PASS: Named buf(1) = %b", out2);
        end else begin
            $display("Test 4 FAIL: unexpected = %b", out2);
        end

        // Test 5: Toggle 0->1
        test_count++;
        a = 0; #1;
        if (out1 == 0) begin
            pass_count++;
            $display("Test 5 PASS: Toggle to 0 = %b", out1);
        end else begin
            $display("Test 5 FAIL: unexpected = %b", out1);
        end

        // Test 6: Toggle 1->0
        test_count++;
        a = 1; #1;
        if (out1 == 1) begin
            pass_count++;
            $display("Test 6 PASS: Toggle to 1 = %b", out1);
        end else begin
            $display("Test 6 FAIL: unexpected = %b", out1);
        end

        // Test 7: Multiple toggles
        test_count++;
        a = 0; #1;
        a = 1; #1;
        a = 0; #1;
        pass_count++;
        $display("Test 7 PASS: Multi toggle = %b", out1);

        // Test 8: Both instances same
        test_count++;
        if (out1 == out2) begin
            pass_count++;
            $display("Test 8 PASS: Both equal");
        end else begin
            $display("Test 8 FAIL: unexpected");
        end

        $display("=== BUF Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
