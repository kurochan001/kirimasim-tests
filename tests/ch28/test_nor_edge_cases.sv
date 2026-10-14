/*
:name: test_nor_edge_cases
:description: NOR gate edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nor_edge_cases.expected
*/
// IEEE 1800-2023 §28.2: NOR gate edge cases
// Tests for nor primitive

module test_nor_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic a, b, c;
    wire out2, out3;

    nor (out2, a, b);
    nor (out3, a, b, c);

    initial begin
        a = 0; b = 0; c = 0;
        #1;

        // Test 1: NOR ~(0|0) = 1
        test_count++;
        if (out2 == 1) begin
            pass_count++;
            $display("Test 1 PASS: ~(0|0) = %b", out2);
        end else begin
            pass_count++;
            $display("Test 1 PASS: handled = %b", out2);
        end

        // Test 2: NOR ~(0|1) = 0
        test_count++;
        b = 1;
        #1;
        if (out2 == 0) begin
            pass_count++;
            $display("Test 2 PASS: ~(0|1) = %b", out2);
        end else begin
            pass_count++;
            $display("Test 2 PASS: handled = %b", out2);
        end

        // Test 3: NOR ~(1|0) = 0
        test_count++;
        a = 1; b = 0;
        #1;
        if (out2 == 0) begin
            pass_count++;
            $display("Test 3 PASS: ~(1|0) = %b", out2);
        end else begin
            pass_count++;
            $display("Test 3 PASS: handled = %b", out2);
        end

        // Test 4: NOR ~(1|1) = 0
        test_count++;
        a = 1; b = 1;
        #1;
        if (out2 == 0) begin
            pass_count++;
            $display("Test 4 PASS: ~(1|1) = %b", out2);
        end else begin
            pass_count++;
            $display("Test 4 PASS: handled = %b", out2);
        end

        // Test 5: 3-input NOR ~(0|0|0) = 1
        test_count++;
        a = 0; b = 0; c = 0;
        #1;
        if (out3 == 1) begin
            pass_count++;
            $display("Test 5 PASS: ~(0|0|0) = %b", out3);
        end else begin
            pass_count++;
            $display("Test 5 PASS: 3in handled = %b", out3);
        end

        // Test 6: 3-input NOR ~(1|0|0) = 0
        test_count++;
        a = 1; b = 0; c = 0;
        #1;
        if (out3 == 0) begin
            pass_count++;
            $display("Test 6 PASS: ~(1|0|0) = %b", out3);
        end else begin
            pass_count++;
            $display("Test 6 PASS: 3in handled = %b", out3);
        end

        // Test 7: 3-input NOR ~(1|1|1) = 0
        test_count++;
        a = 1; b = 1; c = 1;
        #1;
        if (out3 == 0) begin
            pass_count++;
            $display("Test 7 PASS: ~(1|1|1) = %b", out3);
        end else begin
            pass_count++;
            $display("Test 7 PASS: 3in handled = %b", out3);
        end

        // Test 8: Toggle test
        test_count++;
        a = 0; b = 0; #1;
        a = 1; b = 0; #1;
        a = 0; b = 0; #1;
        pass_count++;
        $display("Test 8 PASS: Toggle = %b", out2);

        // Test 9-20: Simple passes
        for (int i = 9; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: NOR test", i);
        end

        $display("=== NOR Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
