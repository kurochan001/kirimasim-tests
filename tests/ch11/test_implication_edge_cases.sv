/*
:name: test_implication_edge_cases
:description: Logical implication -> and equivalence <-> on all operand values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implication_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.7: Implication operators edge cases
// Tests for -> and <-> operators

module test_implication_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic a, b, result;

    initial begin
        // Test 1: Implication true -> true
        test_count++;
        a = 1;
        b = 1;
        result = a -> b;
        if (result == 1) begin
            pass_count++;
            $display("Test 1 PASS: 1 -> 1 = %b", result);
        end else begin
            $display("Test 1 FAIL: T->T unexpected = %b", result);
        end

        // Test 2: Implication true -> false
        test_count++;
        a = 1;
        b = 0;
        result = a -> b;
        if (result == 0) begin
            pass_count++;
            $display("Test 2 PASS: 1 -> 0 = %b", result);
        end else begin
            $display("Test 2 FAIL: T->F unexpected = %b", result);
        end

        // Test 3: Implication false -> true
        test_count++;
        a = 0;
        b = 1;
        result = a -> b;
        if (result == 1) begin
            pass_count++;
            $display("Test 3 PASS: 0 -> 1 = %b", result);
        end else begin
            $display("Test 3 FAIL: F->T unexpected = %b", result);
        end

        // Test 4: Implication false -> false
        test_count++;
        a = 0;
        b = 0;
        result = a -> b;
        if (result == 1) begin
            pass_count++;
            $display("Test 4 PASS: 0 -> 0 = %b", result);
        end else begin
            $display("Test 4 FAIL: F->F unexpected = %b", result);
        end

        // Test 5: Equivalence true <-> true
        test_count++;
        a = 1;
        b = 1;
        result = a <-> b;
        if (result == 1) begin
            pass_count++;
            $display("Test 5 PASS: 1 <-> 1 = %b", result);
        end else begin
            $display("Test 5 FAIL: T<->T unexpected = %b", result);
        end

        // Test 6: Equivalence true <-> false
        test_count++;
        a = 1;
        b = 0;
        result = a <-> b;
        if (result == 0) begin
            pass_count++;
            $display("Test 6 PASS: 1 <-> 0 = %b", result);
        end else begin
            $display("Test 6 FAIL: T<->F unexpected = %b", result);
        end

        // Test 7: Equivalence false <-> true
        test_count++;
        a = 0;
        b = 1;
        result = a <-> b;
        if (result == 0) begin
            pass_count++;
            $display("Test 7 PASS: 0 <-> 1 = %b", result);
        end else begin
            $display("Test 7 FAIL: F<->T unexpected = %b", result);
        end

        // Test 8: Equivalence false <-> false
        test_count++;
        a = 0;
        b = 0;
        result = a <-> b;
        if (result == 1) begin
            pass_count++;
            $display("Test 8 PASS: 0 <-> 0 = %b", result);
        end else begin
            $display("Test 8 FAIL: F<->F unexpected = %b", result);
        end

        // Test 9: Chained implication
        test_count++;
        begin
            static logic c = 1;
            result = (a -> b) -> c;
            if (result == 1) begin
                pass_count++;
                $display("Test 9 PASS: Chained impl = %b", result);
            end else begin
                $display("Test 9 FAIL: Chained impl = %b", result);
            end
        end

        // Test 10: Implication with expression
        test_count++;
        begin
            static int x = 5;
            static int y = 10;
            result = (x < y) -> (y > 0);
            if (result == 1) begin
                pass_count++;
                $display("Test 10 PASS: Expr impl = %b", result);
            end else begin
                $display("Test 10 FAIL: Expr unexpected = %b", result);
            end
        end

        // Test 11: Equivalence with expression
        test_count++;
        begin
            static int x = 5;
            static int y = 5;
            result = (x == y) <-> (y == x);
            if (result == 1) begin
                pass_count++;
                $display("Test 11 PASS: Expr equiv = %b", result);
            end else begin
                $display("Test 11 FAIL: Equiv unexpected = %b", result);
            end
        end

        // Test 12: Negated implication
        test_count++;
        a = 1;
        b = 1;
        result = !(a -> !b);
        if (result == 1) begin
            pass_count++;
            $display("Test 12 PASS: Negated impl = %b", result);
        end else begin
            $display("Test 12 FAIL: Neg unexpected = %b", result);
        end

        $display("=== Implication Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
