/*
:name: test_reduction_corner
:description: Reduction operators, including an operand with an x bit
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_reduction_corner.expected
*/
// Reduction operators, including an operand with an x bit
`timescale 1ns/1ps

module test_reduction_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: AND reduction
    task test_and_reduction();
        logic [7:0] val;
        logic result;

        val = 8'hFF;
        result = &val;
        if (result == 1) begin
            $display("PASS: AND reduction of 0xFF = 1");
            pass_count++;
        end else begin
            $display("FAIL: AND reduction of 0xFF failed");
            fail_count++;
        end

        val = 8'hFE;
        result = &val;
        if (result == 0) begin
            $display("PASS: AND reduction of 0xFE = 0");
            pass_count++;
        end else begin
            $display("FAIL: AND reduction of 0xFE failed");
            fail_count++;
        end
    endtask

    // Test 2: OR reduction
    task test_or_reduction();
        logic [7:0] val;
        logic result;

        val = 8'h00;
        result = |val;
        if (result == 0) begin
            $display("PASS: OR reduction of 0x00 = 0");
            pass_count++;
        end else begin
            $display("FAIL: OR reduction of 0x00 failed");
            fail_count++;
        end

        val = 8'h01;
        result = |val;
        if (result == 1) begin
            $display("PASS: OR reduction of 0x01 = 1");
            pass_count++;
        end else begin
            $display("FAIL: OR reduction of 0x01 failed");
            fail_count++;
        end
    endtask

    // Test 3: XOR reduction (parity)
    task test_xor_reduction();
        logic [7:0] val;
        logic result;

        val = 8'b00001111;  // 4 ones = even parity
        result = ^val;
        if (result == 0) begin
            $display("PASS: XOR reduction of 4 ones = 0 (even parity)");
            pass_count++;
        end else begin
            $display("FAIL: XOR reduction even parity failed");
            fail_count++;
        end

        val = 8'b00001110;  // 3 ones = odd parity
        result = ^val;
        if (result == 1) begin
            $display("PASS: XOR reduction of 3 ones = 1 (odd parity)");
            pass_count++;
        end else begin
            $display("FAIL: XOR reduction odd parity failed");
            fail_count++;
        end
    endtask

    // Test 4: NAND reduction
    task test_nand_reduction();
        logic [7:0] val;
        logic result;

        val = 8'hFF;
        result = ~&val;
        if (result == 0) begin
            $display("PASS: NAND reduction of 0xFF = 0");
            pass_count++;
        end else begin
            $display("FAIL: NAND reduction of 0xFF failed");
            fail_count++;
        end

        val = 8'h00;
        result = ~&val;
        if (result == 1) begin
            $display("PASS: NAND reduction of 0x00 = 1");
            pass_count++;
        end else begin
            $display("FAIL: NAND reduction of 0x00 failed");
            fail_count++;
        end
    endtask

    // Test 5: NOR reduction
    task test_nor_reduction();
        logic [7:0] val;
        logic result;

        val = 8'h00;
        result = ~|val;
        if (result == 1) begin
            $display("PASS: NOR reduction of 0x00 = 1");
            pass_count++;
        end else begin
            $display("FAIL: NOR reduction of 0x00 failed");
            fail_count++;
        end

        val = 8'hFF;
        result = ~|val;
        if (result == 0) begin
            $display("PASS: NOR reduction of 0xFF = 0");
            pass_count++;
        end else begin
            $display("FAIL: NOR reduction of 0xFF failed");
            fail_count++;
        end
    endtask

    // Test 6: XNOR reduction
    task test_xnor_reduction();
        logic [7:0] val;
        logic result;

        val = 8'b00001111;  // 4 ones
        result = ~^val;
        if (result == 1) begin
            $display("PASS: XNOR reduction of 4 ones = 1");
            pass_count++;
        end else begin
            $display("FAIL: XNOR reduction failed");
            fail_count++;
        end
    endtask

    // Test 7: Reduction on single bit
    task test_single_bit();
        logic val;
        logic result;

        val = 1;
        result = &val;
        if (result == 1) begin
            $display("PASS: AND reduction of single bit 1 = 1");
            pass_count++;
        end else begin
            $display("FAIL: Single bit reduction failed");
            fail_count++;
        end
    endtask

    // Test 8: Reduction with X values
    task test_x_values();
        logic [3:0] val;
        logic result;

        val = 4'b1x01;
        result = |val;
        // OR of 1,x,0,1 should be 1 (because at least one bit is 1)
        if (result === 1'b1) begin
            $display("PASS: OR reduction with X handles known 1");
            pass_count++;
        end else begin
            $display("FAIL: OR reduction with X (result: %b)", result);
            fail_count++;
        end
    endtask

    // Test 9: Reduction in expression
    task test_reduction_in_expr();
        logic [7:0] a, b;
        logic result;

        a = 8'hFF;
        b = 8'h00;
        result = (&a) & (~|b);

        if (result == 1) begin
            $display("PASS: Reduction in expression works");
            pass_count++;
        end else begin
            $display("FAIL: Reduction in expression failed");
            fail_count++;
        end
    endtask

    // Test 10: Reduction on wide vector
    task test_wide_reduction();
        logic [63:0] wide_val;
        logic result;

        wide_val = 64'hFFFFFFFFFFFFFFFF;
        result = &wide_val;
        if (result == 1) begin
            $display("PASS: AND reduction of 64-bit all-ones = 1");
            pass_count++;
        end else begin
            $display("FAIL: Wide reduction failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Reduction Operators Corner Cases Test ===");

        test_and_reduction();
        test_or_reduction();
        test_xor_reduction();
        test_nand_reduction();
        test_nor_reduction();
        test_xnor_reduction();
        test_single_bit();
        test_x_values();
        test_reduction_in_expr();
        test_wide_reduction();

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
