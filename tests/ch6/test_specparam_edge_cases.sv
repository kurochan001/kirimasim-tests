/*
:name: test_specparam_edge_cases
:description: specparam values used in expressions in the module body
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_edge_cases.expected
*/
// IEEE 1800-2023 §6.20.5: Specparam edge cases
// Tests for specify parameters

module test_specparam_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    specparam tpd = 10;
    specparam tsetup = 5;
    specparam thold = 3;
    specparam [7:0] twidth = 8'd20;

    initial begin
        // Test 1: Specparam default
        test_count++;
        if (tpd == 10) begin
            pass_count++;
            $display("Test 1 PASS: tpd = %0d", tpd);
        end else begin
            $display("Test 1 FAIL: tpd unexpected = %0d", tpd);
        end

        // Test 2: Specparam setup
        test_count++;
        if (tsetup == 5) begin
            pass_count++;
            $display("Test 2 PASS: tsetup = %0d", tsetup);
        end else begin
            $display("Test 2 FAIL: tsetup unexpected = %0d", tsetup);
        end

        // Test 3: Specparam hold
        test_count++;
        if (thold == 3) begin
            pass_count++;
            $display("Test 3 PASS: thold = %0d", thold);
        end else begin
            $display("Test 3 FAIL: thold unexpected = %0d", thold);
        end

        // Test 4: Specparam with range
        test_count++;
        if (twidth == 20) begin
            pass_count++;
            $display("Test 4 PASS: twidth = %0d", twidth);
        end else begin
            $display("Test 4 FAIL: twidth unexpected = %0d", twidth);
        end

        // Test 5: Specparam in expression
        test_count++;
        begin
            static int sum = tpd + tsetup + thold;
            if (sum == 18) begin
                pass_count++;
                $display("Test 5 PASS: sum = %0d", sum);
            end else begin
                $display("Test 5 FAIL: sum unexpected = %0d", sum);
            end
        end

        // Test 6: Specparam comparison
        test_count++;
        if (tpd > tsetup) begin
            pass_count++;
            $display("Test 6 PASS: tpd > tsetup");
        end else begin
            $display("Test 6 FAIL: Compare unexpected");
        end

        // Test 7: Specparam multiplication
        test_count++;
        begin
            static int prod = tpd * 2;
            if (prod == 20) begin
                pass_count++;
                $display("Test 7 PASS: prod = %0d", prod);
            end else begin
                $display("Test 7 FAIL: prod unexpected = %0d", prod);
            end
        end

        // Test 8: Specparam division
        test_count++;
        begin
            static int quot = tpd / 2;
            if (quot == 5) begin
                pass_count++;
                $display("Test 8 PASS: quot = %0d", quot);
            end else begin
                $display("Test 8 FAIL: quot unexpected = %0d", quot);
            end
        end

        // Test 9: Specparam ternary
        test_count++;
        begin
            static int result = (tpd > 5) ? tpd : tsetup;
            if (result == tpd) begin
                pass_count++;
                $display("Test 9 PASS: ternary = %0d", result);
            end else begin
                $display("Test 9 FAIL: ternary unexpected = %0d", result);
            end
        end

        // Test 10: Specparam equality with self
        test_count++;
        if (tpd == 10) begin
            pass_count++;
            $display("Test 10 PASS: tpd == 10");
        end else begin
            $display("Test 10 FAIL: equal unexpected");
        end

        $display("=== Specparam Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
