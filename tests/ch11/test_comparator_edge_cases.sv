/*
:name: test_comparator_edge_cases
:description: Comparator edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comparator_edge_cases.expected
*/
// IEEE 1800-2023: Comparator edge cases
// Tests for comparison constructs

module test_comparator_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b;
    logic eq, ne, lt, le, gt, ge;
    logic signed [7:0] sa, sb;
    logic s_lt, s_gt;

    // Unsigned comparator
    assign eq = (a == b);
    assign ne = (a != b);
    assign lt = (a < b);
    assign le = (a <= b);
    assign gt = (a > b);
    assign ge = (a >= b);

    // Signed comparator
    assign s_lt = (sa < sb);
    assign s_gt = (sa > sb);

    initial begin
        // Test 1: Equal values
        test_count++;
        a = 8'h55; b = 8'h55;
        #1;
        if (eq == 1 && ne == 0) begin
            pass_count++;
            $display("Test 1 PASS: eq=%b ne=%b", eq, ne);
        end else begin
            $display("Test 1 FAIL: unexpected");
        end

        // Test 2: Less than
        test_count++;
        a = 8'h10; b = 8'h20;
        #1;
        if (lt == 1 && gt == 0) begin
            pass_count++;
            $display("Test 2 PASS: %h < %h", a, b);
        end else begin
            $display("Test 2 FAIL: unexpected");
        end

        // Test 3: Greater than
        test_count++;
        a = 8'hFF; b = 8'h00;
        #1;
        if (gt == 1 && lt == 0) begin
            pass_count++;
            $display("Test 3 PASS: %h > %h", a, b);
        end else begin
            $display("Test 3 FAIL: unexpected");
        end

        // Test 4: Less than or equal (equal)
        test_count++;
        a = 8'hAA; b = 8'hAA;
        #1;
        if (le == 1 && ge == 1) begin
            pass_count++;
            $display("Test 4 PASS: le=%b ge=%b", le, ge);
        end else begin
            $display("Test 4 FAIL: unexpected");
        end

        // Test 5: Signed comparison - negative vs positive
        test_count++;
        sa = -1; sb = 1;
        #1;
        if (s_lt == 1) begin
            pass_count++;
            $display("Test 5 PASS: signed -1 < 1");
        end else begin
            $display("Test 5 FAIL: unexpected s_lt=%b", s_lt);
        end

        // Test 6: Signed comparison - both negative
        test_count++;
        sa = -10; sb = -5;
        #1;
        if (s_lt == 1) begin
            pass_count++;
            $display("Test 6 PASS: signed -10 < -5");
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: Zero comparison
        test_count++;
        a = 0; b = 0;
        #1;
        if (eq == 1 && le == 1 && ge == 1) begin
            pass_count++;
            $display("Test 7 PASS: 0 == 0");
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Comparator Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
