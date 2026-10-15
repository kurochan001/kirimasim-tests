/*
:name: test_operator_shift
:description: Shift operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_shift.expected
*/
// Shift operators
module test_operator_shift;
    logic [7:0] a, result;
    logic signed [7:0] sa, sresult;
    int ia;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Logical left shift (<<)
        a = 8'h01;
        result = a << 4;
        if (result == 8'h10) begin
            $display("PASS: Test 1 - Logical left shift");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x10, got 0x%h", result);
            fail_count++;
        end

        // Test 2: Logical right shift (>>)
        a = 8'h80;
        result = a >> 4;
        if (result == 8'h08) begin
            $display("PASS: Test 2 - Logical right shift");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0x08, got 0x%h", result);
            fail_count++;
        end

        // Test 3: Arithmetic left shift (<<<)
        sa = 8'sh01;
        sresult = sa <<< 4;
        if (sresult == 8'sh10) begin
            $display("PASS: Test 3 - Arithmetic left shift");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0x10, got 0x%h", sresult);
            fail_count++;
        end

        // Test 4: Arithmetic right shift (>>>) - sign extension
        sa = 8'sh80;  // -128
        sresult = sa >>> 4;
        if (sresult == 8'shF8) begin  // -8, with sign extension
            $display("PASS: Test 4 - Arithmetic right shift (sign extension)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0xF8, got 0x%h", sresult);
            fail_count++;
        end

        // Test 5: Shift by variable amount
        a = 8'hFF;
        ia = 3;
        result = a << ia;
        if (result == 8'hF8) begin
            $display("PASS: Test 5 - Variable shift amount");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xF8, got 0x%h", result);
            fail_count++;
        end

        // Summary
        $display("Operator Shift: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
