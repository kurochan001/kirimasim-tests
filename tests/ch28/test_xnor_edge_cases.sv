/*
:name: test_xnor_edge_cases
:description: XNOR gate edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_xnor_edge_cases.expected
*/
// IEEE 1800-2023 §28.4: XNOR gate edge cases
// Tests for xnor primitive

module test_xnor_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic a, b, c;
    wire out2, out3;

    xnor (out2, a, b);
    xnor (out3, a, b, c);

    initial begin
        a = 0; b = 0; c = 0;
        #1;

        // Test 1: XNOR 0~^0 = 1
        test_count++;
        if (out2 == 1) begin
            pass_count++;
            $display("Test 1 PASS: 0~^0 = %b", out2);
        end else begin
            $display("Test 1 FAIL: 0~^0 unexpected = %b", out2);
        end

        // Test 2: XNOR 0~^1 = 0
        test_count++;
        b = 1;
        #1;
        if (out2 == 0) begin
            pass_count++;
            $display("Test 2 PASS: 0~^1 = %b", out2);
        end else begin
            $display("Test 2 FAIL: 0~^1 unexpected = %b", out2);
        end

        // Test 3: XNOR 1~^0 = 0
        test_count++;
        a = 1; b = 0;
        #1;
        if (out2 == 0) begin
            pass_count++;
            $display("Test 3 PASS: 1~^0 = %b", out2);
        end else begin
            $display("Test 3 FAIL: 1~^0 unexpected = %b", out2);
        end

        // Test 4: XNOR 1~^1 = 1
        test_count++;
        a = 1; b = 1;
        #1;
        if (out2 == 1) begin
            pass_count++;
            $display("Test 4 PASS: 1~^1 = %b", out2);
        end else begin
            $display("Test 4 FAIL: 1~^1 unexpected = %b", out2);
        end

        // Test 5: 3-input XNOR 0~^0~^0 = 1
        test_count++;
        a = 0; b = 0; c = 0;
        #1;
        if (out3 == 1) begin
            pass_count++;
            $display("Test 5 PASS: 0~^0~^0 = %b", out3);
        end else begin
            $display("Test 5 FAIL: 3in unexpected = %b", out3);
        end

        // Test 6: 3-input XNOR 1~^0~^0 = 0
        test_count++;
        a = 1; b = 0; c = 0;
        #1;
        if (out3 == 0) begin
            pass_count++;
            $display("Test 6 PASS: 1~^0~^0 = %b", out3);
        end else begin
            $display("Test 6 FAIL: 3in unexpected = %b", out3);
        end

        // Test 7: 3-input XNOR 1~^1~^0 = 1
        test_count++;
        a = 1; b = 1; c = 0;
        #1;
        if (out3 == 1) begin
            pass_count++;
            $display("Test 7 PASS: 1~^1~^0 = %b", out3);
        end else begin
            $display("Test 7 FAIL: 3in unexpected = %b", out3);
        end

        // Test 8: 3-input XNOR 1~^1~^1 = 0
        test_count++;
        a = 1; b = 1; c = 1;
        #1;
        if (out3 == 0) begin
            pass_count++;
            $display("Test 8 PASS: 1~^1~^1 = %b", out3);
        end else begin
            $display("Test 8 FAIL: 3in unexpected = %b", out3);
        end

        $display("=== XNOR Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
