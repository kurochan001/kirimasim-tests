/*
:name: test_operator_logical
:description: Logical operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_logical.expected
*/
// Logical operators
module test_operator_logical;
    logic a, b, result;
    logic [7:0] vec_a, vec_b;
    int ia, ib;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Logical AND (&&)
        a = 1'b1;
        b = 1'b1;
        if ((a && b) == 1'b1 && (a && 1'b0) == 1'b0 && (1'b0 && b) == 1'b0) begin
            $display("PASS: Test 1 - Logical AND");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Logical AND failed");
            fail_count++;
        end

        // Test 2: Logical OR (||)
        a = 1'b0;
        b = 1'b0;
        if ((a || b) == 1'b0 && (a || 1'b1) == 1'b1 && (1'b1 || b) == 1'b1) begin
            $display("PASS: Test 2 - Logical OR");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Logical OR failed");
            fail_count++;
        end

        // Test 3: Logical NOT (!)
        a = 1'b1;
        b = 1'b0;
        if ((!a == 1'b0) && (!b == 1'b1)) begin
            $display("PASS: Test 3 - Logical NOT");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Logical NOT failed");
            fail_count++;
        end

        // Test 4: Logical operators on vectors (non-zero = true)
        vec_a = 8'hFF;
        vec_b = 8'h00;
        if ((vec_a && vec_a) == 1'b1 && (vec_a && vec_b) == 1'b0 &&
            (vec_a || vec_b) == 1'b1 && (!vec_b) == 1'b1) begin
            $display("PASS: Test 4 - Logical ops on vectors");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Logical ops on vectors failed");
            fail_count++;
        end

        // Test 5: Logical implication (->)
        a = 1'b1;
        b = 1'b0;
        // a -> b is equivalent to !a || b
        if (((1'b0 -> 1'b0) == 1'b1) && ((1'b0 -> 1'b1) == 1'b1) &&
            ((1'b1 -> 1'b1) == 1'b1) && ((1'b1 -> 1'b0) == 1'b0)) begin
            $display("PASS: Test 5 - Logical implication");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Logical implication failed");
            fail_count++;
        end

        // Summary
        $display("Operator Logical: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
