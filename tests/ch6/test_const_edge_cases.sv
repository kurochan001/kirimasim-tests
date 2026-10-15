/*
:name: test_const_edge_cases
:description: Const variables edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.6 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_const_edge_cases.expected
*/
// IEEE 1800-2023 §6.20: Const variables edge cases
// Tests for const declarations

module test_const_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    const int CONST_VAL = 100;
    const logic [7:0] CONST_BYTE = 8'hAB;
    const string CONST_STR = "hello";
    const int CONST_ARR[4] = '{1, 2, 3, 4};

    initial begin
        // Test 1: Read const int
        test_count++;
        if (CONST_VAL == 100) begin
            pass_count++;
            $display("Test 1 PASS: CONST_VAL = %0d", CONST_VAL);
        end else begin
            $display("Test 1 FAIL: const int unexpected");
        end

        // Test 2: Read const byte
        test_count++;
        if (CONST_BYTE == 8'hAB) begin
            pass_count++;
            $display("Test 2 PASS: CONST_BYTE = %h", CONST_BYTE);
        end else begin
            $display("Test 2 FAIL: const byte unexpected");
        end

        // Test 3: Read const string
        test_count++;
        if (CONST_STR == "hello") begin
            pass_count++;
            $display("Test 3 PASS: CONST_STR = %s", CONST_STR);
        end else begin
            $display("Test 3 FAIL: const string unexpected");
        end

        // Test 4: Read const array
        test_count++;
        if (CONST_ARR[0] == 1 && CONST_ARR[3] == 4) begin
            pass_count++;
            $display("Test 4 PASS: CONST_ARR[0]=%0d [3]=%0d", CONST_ARR[0], CONST_ARR[3]);
        end else begin
            $display("Test 4 FAIL: const array unexpected");
        end

        // Test 5: Const in expression
        test_count++;
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = CONST_VAL * 2;
            if (result == 200) begin
                pass_count++;
                $display("Test 5 PASS: CONST_VAL * 2 = %0d", result);
            end else begin
                $display("Test 5 FAIL: expr unexpected = %0d", result);
            end
        end

        // Test 6: Const in comparison
        test_count++;
        begin
            static int x = 100;
            if (x == CONST_VAL) begin
                pass_count++;
                $display("Test 6 PASS: x == CONST_VAL");
            end else begin
                $display("Test 6 FAIL: compare unexpected");
            end
        end

        // Test 7: Local const
        test_count++;
        begin
            const static int LOCAL_CONST = 50;
            if (LOCAL_CONST == 50) begin
                pass_count++;
                $display("Test 7 PASS: LOCAL_CONST = %0d", LOCAL_CONST);
            end else begin
                $display("Test 7 FAIL: local const unexpected");
            end
        end

        // Test 8: Const array sum
        test_count++;
        begin
            static int sum = 0;
            for (int i = 0; i < 4; i++) sum += CONST_ARR[i];
            if (sum == 10) begin
                pass_count++;
                $display("Test 8 PASS: array sum = %0d", sum);
            end else begin
                $display("Test 8 FAIL: sum unexpected = %0d", sum);
            end
        end

        // Test 9: Const string length
        test_count++;
        begin
            static int len;
            // Assigned here so the result does not depend on the order of static initializers.
            len = CONST_STR.len();
            if (len == 5) begin
                pass_count++;
                $display("Test 9 PASS: CONST_STR.len() = %0d", len);
            end else begin
                $display("Test 9 FAIL: len unexpected = %0d", len);
            end
        end

        // Test 10: Const byte operations
        test_count++;
        begin
            static logic [7:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = CONST_BYTE & 8'hF0;
            if (result == 8'hA0) begin
                pass_count++;
                $display("Test 10 PASS: CONST_BYTE & F0 = %h", result);
            end else begin
                $display("Test 10 FAIL: byte op unexpected = %h", result);
            end
        end

        // Test 11: Const in conditional
        test_count++;
        begin
            static int x;
            // Assigned here so the result does not depend on the order of static initializers.
            x = (CONST_VAL > 50) ? 1 : 0;
            if (x == 1) begin
                pass_count++;
                $display("Test 11 PASS: conditional const");
            end else begin
                $display("Test 11 FAIL: cond unexpected");
            end
        end

        // Test 12: Multiple const usage
        test_count++;
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = CONST_VAL + CONST_BYTE + CONST_ARR[0];
            pass_count++;
            $display("Test 12 PASS: multi const = %0d", result);
        end

        $display("=== Const Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
