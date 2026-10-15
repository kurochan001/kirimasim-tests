/*
:name: test_operator_equality
:description: Equality operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_equality.expected
*/
// Equality operators
module test_operator_equality;
    logic [3:0] a, b;
    logic [3:0] ax, bx;
    int ia, ib;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Logical equality (==) and inequality (!=)
        a = 4'b1010;
        b = 4'b1010;
        if ((a == b) && !(a != b)) begin
            $display("PASS: Test 1 - Logical equality");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Logical equality failed");
            fail_count++;
        end

        // Test 2: Logical inequality with different values
        a = 4'b1010;
        b = 4'b0101;
        if ((a != b) && !(a == b)) begin
            $display("PASS: Test 2 - Logical inequality");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Logical inequality failed");
            fail_count++;
        end

        // Test 3: Case equality (===) with X values
        ax = 4'b10x1;
        bx = 4'b10x1;
        if (ax === bx) begin
            $display("PASS: Test 3 - Case equality with X");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Case equality with X failed");
            fail_count++;
        end

        // Test 4: Case inequality (!==) with X values
        ax = 4'b10x1;
        bx = 4'b10x0;
        if (ax !== bx) begin
            $display("PASS: Test 4 - Case inequality with X");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Case inequality with X failed");
            fail_count++;
        end

        // Test 5: Wildcard equality (==?) and (!=?)
        a = 4'b1010;
        bx = 4'b10?0;  // ? matches any bit
        if (a ==? bx) begin
            $display("PASS: Test 5 - Wildcard equality");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Wildcard equality failed");
            fail_count++;
        end

        // Summary
        $display("Operator Equality: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
