/*
:name: test_x_z_propagation
:description: X and Z values in arithmetic, comparison, conditional operator, reduction, if and casez (IEEE 1800-2023 Sections 11.4, 12.4, 12.5.1 and 20.9)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.5 11.4.11 12.4 12.5.1 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_x_z_propagation.expected
*/
// X and Z values in arithmetic, comparison, conditional operator, reduction, if and casez (IEEE 1800-2023 Sections 11.4, 12.4, 12.5.1 and 20.9)
`timescale 1ns/1ps

module test_x_z_propagation;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: X propagation in arithmetic
    task test_x_arithmetic();
        static logic [7:0] a = 8'h55;
        static logic [7:0] b = 8'hxx;
        logic [7:0] result;

        result = a + b;

        // Adding X should produce X
        if ($isunknown(result)) begin
            $display("PASS: X propagates in addition");
            pass_count++;
        end else begin
            $display("FAIL: Arithmetic with X (result=%h)", result);
            fail_count++;
        end
    endtask

    // Test 2: X in comparison
    task test_x_comparison();
        static logic [7:0] a = 8'hxx;
        static logic [7:0] b = 8'hxx;
        logic result;

        result = (a == b);

        // X == X is X in 4-state logic (11.4.5)
        if (result === 1'bx) begin
            $display("PASS: X comparison handled (result=%b)", result);
            pass_count++;
        end else begin
            $display("FAIL: X comparison (result=%b)", result);
            fail_count++;
        end
    endtask

    // Test 3: X in logical operations
    task test_x_logical();
        static logic a = 1'bx;
        logic result_and, result_or;

        result_and = a & 1'b0;  // X & 0 = 0
        result_or = a | 1'b1;   // X | 1 = 1

        if (result_and == 0 && result_or == 1) begin
            $display("PASS: X logical optimization works");
            pass_count++;
        end else begin
            $display("FAIL: X logical (and=%b, or=%b)", result_and, result_or);
            fail_count++;
        end
    endtask

    // Test 4: Z value handling
    task test_z_value();
        static logic [7:0] val_z = 8'hzz;
        static logic [7:0] val_normal = 8'hAA;
        logic [7:0] result;

        // Z value assignment and comparison
        result = val_z;

        // Check Z value is preserved
        if (result === 8'hzz) begin
            $display("PASS: Z value preserved in assignment");
            pass_count++;
        end else begin
            $display("FAIL: Z value handling (result=%h)", result);
            fail_count++;
        end
    endtask

    // Test 5: Case equality with X/Z
    task test_case_equality();
        static logic [3:0] a = 4'b1x0z;
        static logic [3:0] b = 4'b1x0z;
        logic eq, case_eq;

        eq = (a == b);
        case_eq = (a === b);

        if (case_eq == 1) begin
            $display("PASS: Case equality (===) matches X and Z exactly");
            pass_count++;
        end else begin
            $display("FAIL: Case equality failed");
            fail_count++;
        end
    endtask

    // Test 6: Case inequality with X/Z
    task test_case_inequality();
        static logic [3:0] a = 4'b1x0z;
        static logic [3:0] b = 4'b1x00;
        logic case_neq;

        case_neq = (a !== b);

        if (case_neq == 1) begin
            $display("PASS: Case inequality (!==) works");
            pass_count++;
        end else begin
            $display("FAIL: Case inequality failed");
            fail_count++;
        end
    endtask

    // Test 7: $isunknown system function
    task test_isunknown();
        static logic [7:0] known = 8'hAB;
        static logic [7:0] unknown = 8'hxz;

        if (!$isunknown(known) && $isunknown(unknown)) begin
            $display("PASS: $isunknown works correctly");
            pass_count++;
        end else begin
            $display("FAIL: $isunknown failed");
            fail_count++;
        end
    endtask

    // Test 8: X in case statement
    task test_x_in_case();
        static logic [1:0] sel = 2'bx1;
        static int result = -1;

        casez (sel)
            2'b00: result = 0;
            2'b01: result = 1;
            2'b?1: result = 2;  // Matches x1
            default: result = 99;
        endcase

        if (result == 2) begin
            $display("PASS: casez handles X as wildcard match");
            pass_count++;
        end else begin
            $display("FAIL: casez with X (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 9: X propagation through MUX
    task test_x_mux();
        static logic sel = 1'bx;
        static logic [7:0] a = 8'hAA;
        static logic [7:0] b = 8'hBB;
        logic [7:0] result;

        result = sel ? a : b;

        // With an X select, bits that differ between a and b become X (11.4.11)
        if (result === 8'b101x_101x) begin
            $display("PASS: MUX with X select handled (result=%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: MUX with X select (result=%b)", result);
            fail_count++;
        end
    endtask

    // Test 10: Reduction with X
    task test_x_reduction();
        static logic [3:0] val = 4'b1x10;
        logic or_result, and_result;

        or_result = |val;   // Has 1, so OR is 1
        and_result = &val;  // Has 0, so AND is 0

        if (or_result == 1 && and_result == 0) begin
            $display("PASS: Reduction with X uses known bits");
            pass_count++;
        end else begin
            $display("FAIL: Reduction with X (or=%b, and=%b)", or_result, and_result);
            fail_count++;
        end
    endtask

    // Test 11: X in conditional
    task test_x_conditional();
        static logic cond = 1'bx;
        int result;

        if (cond)
            result = 1;
        else
            result = 0;

        // An X condition is treated as false (12.4)
        if (result == 0) begin
            $display("PASS: X conditional handled (result=%0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: X conditional (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 12: Z in comparisons
    task test_z_comparison();
        static logic [7:0] a = 8'hzz;
        static logic [7:0] b = 8'hzz;
        logic eq, case_eq;

        eq = (a == b);
        case_eq = (a === b);

        if (case_eq == 1) begin
            $display("PASS: Z comparison with === works");
            pass_count++;
        end else begin
            $display("FAIL: Z comparison failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== X and Z Propagation Test ===");

        test_x_arithmetic();
        test_x_comparison();
        test_x_logical();
        test_z_value();
        test_case_equality();
        test_case_inequality();
        test_isunknown();
        test_x_in_case();
        test_x_mux();
        test_x_reduction();
        test_x_conditional();
        test_z_comparison();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
