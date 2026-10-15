/*
:name: test_operator_assign
:description: Assignment operators test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_assign.expected
*/
// Assignment operators test
module test_operator_assign;
    int a, b;
    logic [7:0] byte_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Simple assignment
        a = 100;
        if (a == 100) begin
            $display("PASS: Simple assignment a = 100");
            pass_count++;
        end else begin
            $display("FAIL: Simple assignment, expected 100, got %0d", a);
            fail_count++;
        end

        // Test 2: Add-assign
        a = 10;
        a += 5;
        if (a == 15) begin
            $display("PASS: Add-assign a += 5: 10 + 5 = 15");
            pass_count++;
        end else begin
            $display("FAIL: Add-assign, expected 15, got %0d", a);
            fail_count++;
        end

        // Test 3: Subtract-assign
        a = 20;
        a -= 8;
        if (a == 12) begin
            $display("PASS: Subtract-assign a -= 8: 20 - 8 = 12");
            pass_count++;
        end else begin
            $display("FAIL: Subtract-assign, expected 12, got %0d", a);
            fail_count++;
        end

        // Test 4: Multiply-assign
        a = 7;
        a *= 6;
        if (a == 42) begin
            $display("PASS: Multiply-assign a *= 6: 7 * 6 = 42");
            pass_count++;
        end else begin
            $display("FAIL: Multiply-assign, expected 42, got %0d", a);
            fail_count++;
        end

        // Test 5: Bitwise AND-assign
        byte_val = 8'hFF;
        byte_val &= 8'h0F;
        if (byte_val == 8'h0F) begin
            $display("PASS: AND-assign 0xFF &= 0x0F = 0x0F");
            pass_count++;
        end else begin
            $display("FAIL: AND-assign, expected 0x0F, got 0x%02X", byte_val);
            fail_count++;
        end

        // Summary
        $display("Assignment operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All assignment operator tests passed");
        else $display("FAIL: Some assignment operator tests failed");
        $finish;
    end
endmodule
