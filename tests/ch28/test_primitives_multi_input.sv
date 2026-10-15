/*
:name: test_primitives_multi_input
:description: Multi-input gate primitives
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_primitives_multi_input.expected
*/
// IEEE 1800-2023 §28: Multi-input gate primitives
// Tests gates with more than 2 inputs

module test_primitives_multi_input;
    int pass_count = 0;
    int test_count = 0;

    logic a, b, c, d;
    logic y_and3, y_and4;
    logic y_or3, y_or4;
    logic y_xor3, y_nand3;

    // 3-input gates
    and g_and3(y_and3, a, b, c);
    or  g_or3(y_or3, a, b, c);
    xor g_xor3(y_xor3, a, b, c);
    nand g_nand3(y_nand3, a, b, c);

    // 4-input gates
    and g_and4(y_and4, a, b, c, d);
    or  g_or4(y_or4, a, b, c, d);

    initial begin
        // Test 1: 3-input AND gate
        test_count++;
        begin
            static int local_pass = 0;
            a = 1; b = 1; c = 1; #1;
            if (y_and3 == 1) local_pass++;
            a = 1; b = 1; c = 0; #1;
            if (y_and3 == 0) local_pass++;
            a = 0; b = 1; c = 1; #1;
            if (y_and3 == 0) local_pass++;
            if (local_pass == 3) begin
                pass_count++;
                $display("Test 1 PASS: 3-input AND gate");
            end else begin
                $display("Test 1 FAIL: 3-input AND gate (%0d/3)", local_pass);
            end
        end

        // Test 2: 3-input OR gate
        test_count++;
        begin
            static int local_pass = 0;
            a = 0; b = 0; c = 0; #1;
            if (y_or3 == 0) local_pass++;
            a = 0; b = 0; c = 1; #1;
            if (y_or3 == 1) local_pass++;
            a = 1; b = 0; c = 0; #1;
            if (y_or3 == 1) local_pass++;
            if (local_pass == 3) begin
                pass_count++;
                $display("Test 2 PASS: 3-input OR gate");
            end else begin
                $display("Test 2 FAIL: 3-input OR gate (%0d/3)", local_pass);
            end
        end

        // Test 3: 3-input XOR gate (odd parity)
        test_count++;
        begin
            static int local_pass = 0;
            a = 0; b = 0; c = 0; #1;
            if (y_xor3 == 0) local_pass++;  // 0 ones = even
            a = 1; b = 0; c = 0; #1;
            if (y_xor3 == 1) local_pass++;  // 1 one = odd
            a = 1; b = 1; c = 0; #1;
            if (y_xor3 == 0) local_pass++;  // 2 ones = even
            a = 1; b = 1; c = 1; #1;
            if (y_xor3 == 1) local_pass++;  // 3 ones = odd
            if (local_pass == 4) begin
                pass_count++;
                $display("Test 3 PASS: 3-input XOR gate (parity)");
            end else begin
                $display("Test 3 FAIL: 3-input XOR gate (%0d/4)", local_pass);
            end
        end

        // Test 4: 3-input NAND gate
        test_count++;
        begin
            static int local_pass = 0;
            a = 1; b = 1; c = 1; #1;
            if (y_nand3 == 0) local_pass++;  // All 1s -> NAND = 0
            a = 1; b = 1; c = 0; #1;
            if (y_nand3 == 1) local_pass++;  // Not all 1s -> NAND = 1
            a = 0; b = 0; c = 0; #1;
            if (y_nand3 == 1) local_pass++;
            if (local_pass == 3) begin
                pass_count++;
                $display("Test 4 PASS: 3-input NAND gate");
            end else begin
                $display("Test 4 FAIL: 3-input NAND gate (%0d/3)", local_pass);
            end
        end

        // Test 5: 4-input AND gate
        test_count++;
        begin
            static int local_pass = 0;
            a = 1; b = 1; c = 1; d = 1; #1;
            if (y_and4 == 1) local_pass++;
            a = 1; b = 1; c = 1; d = 0; #1;
            if (y_and4 == 0) local_pass++;
            a = 0; b = 0; c = 0; d = 0; #1;
            if (y_and4 == 0) local_pass++;
            if (local_pass == 3) begin
                pass_count++;
                $display("Test 5 PASS: 4-input AND gate");
            end else begin
                $display("Test 5 FAIL: 4-input AND gate (%0d/3)", local_pass);
            end
        end

        // Test 6: 4-input OR gate
        test_count++;
        begin
            static int local_pass = 0;
            a = 0; b = 0; c = 0; d = 0; #1;
            if (y_or4 == 0) local_pass++;
            a = 0; b = 0; c = 0; d = 1; #1;
            if (y_or4 == 1) local_pass++;
            a = 1; b = 1; c = 1; d = 1; #1;
            if (y_or4 == 1) local_pass++;
            if (local_pass == 3) begin
                pass_count++;
                $display("Test 6 PASS: 4-input OR gate");
            end else begin
                $display("Test 6 FAIL: 4-input OR gate (%0d/3)", local_pass);
            end
        end

        $display("=== Multi-input Primitives Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
