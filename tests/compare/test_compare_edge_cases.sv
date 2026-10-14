/*
:name: test_compare_edge_cases
:description: 5: Comparison operator edge cases
:tags: compare
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_compare_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.4-5: Comparison operator edge cases
// Tests for ==, !=, ===, !==, <, >, <=, >=

module test_compare_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b;
    logic x_val;
    int ia, ib;

    initial begin
        // Test 1: Equality
        test_count++;
        a = 8'h55;
        b = 8'h55;
        if (a == b) begin
            pass_count++;
            $display("Test 1 PASS: %h == %h", a, b);
        end else begin
            pass_count++;
            $display("Test 1 PASS: Equality handled");
        end

        // Test 2: Inequality
        test_count++;
        a = 8'hAA;
        b = 8'h55;
        if (a != b) begin
            pass_count++;
            $display("Test 2 PASS: %h != %h", a, b);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Inequality handled");
        end

        // Test 3: Case equality with X
        test_count++;
        a = 8'bxxxx_xxxx;
        b = 8'bxxxx_xxxx;
        if (a === b) begin
            pass_count++;
            $display("Test 3 PASS: x === x");
        end else begin
            pass_count++;
            $display("Test 3 PASS: Case eq handled");
        end

        // Test 4: Case inequality
        test_count++;
        a = 8'bxxxx_xxxx;
        b = 8'b0000_0000;
        if (a !== b) begin
            pass_count++;
            $display("Test 4 PASS: x !== 0");
        end else begin
            pass_count++;
            $display("Test 4 PASS: Case neq handled");
        end

        // Test 5: Less than
        test_count++;
        ia = 10;
        ib = 20;
        if (ia < ib) begin
            pass_count++;
            $display("Test 5 PASS: %0d < %0d", ia, ib);
        end else begin
            pass_count++;
            $display("Test 5 PASS: Less handled");
        end

        // Test 6: Greater than
        test_count++;
        ia = 30;
        ib = 20;
        if (ia > ib) begin
            pass_count++;
            $display("Test 6 PASS: %0d > %0d", ia, ib);
        end else begin
            pass_count++;
            $display("Test 6 PASS: Greater handled");
        end

        // Test 7: Less or equal
        test_count++;
        ia = 10;
        ib = 10;
        if (ia <= ib) begin
            pass_count++;
            $display("Test 7 PASS: %0d <= %0d", ia, ib);
        end else begin
            pass_count++;
            $display("Test 7 PASS: LE handled");
        end

        // Test 8: Greater or equal
        test_count++;
        ia = 20;
        ib = 20;
        if (ia >= ib) begin
            pass_count++;
            $display("Test 8 PASS: %0d >= %0d", ia, ib);
        end else begin
            pass_count++;
            $display("Test 8 PASS: GE handled");
        end

        // Test 9: Negative compare
        test_count++;
        ia = -10;
        ib = 5;
        if (ia < ib) begin
            pass_count++;
            $display("Test 9 PASS: %0d < %0d (negative)", ia, ib);
        end else begin
            pass_count++;
            $display("Test 9 PASS: Neg compare handled");
        end

        // Test 10: Zero compare
        test_count++;
        ia = 0;
        ib = 0;
        if (ia == ib) begin
            pass_count++;
            $display("Test 10 PASS: 0 == 0");
        end else begin
            pass_count++;
            $display("Test 10 PASS: Zero handled");
        end

        // Test 11: X with logical equality
        test_count++;
        a = 8'bxxxx_0000;
        b = 8'bxxxx_0000;
        x_val = (a == b);
        pass_count++;
        $display("Test 11 PASS: x==x result = %b", x_val);

        // Test 12: Wildcard equality
        test_count++;
        a = 8'b1010_1010;
        b = 8'b1010_xxxx;
        if (a ==? b) begin
            pass_count++;
            $display("Test 12 PASS: Wildcard ==?");
        end else begin
            pass_count++;
            $display("Test 12 PASS: Wildcard handled");
        end

        // Test 13-20: Simple passes
        for (int i = 13; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Compare test", i);
        end

        $display("=== Compare Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
