/*
:name: test_scanf_advanced
:description: Advanced Scanf Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scanf_advanced.expected
*/
// IEEE 1800-2023 Section 21.3.4.3 - Advanced Scanf Tests
// Tests: complex format strings, mixed types, error handling

module test_scanf_advanced;
    int pass_count = 0;
    int fail_count = 0;

    string input_str;
    int count;
    int i_val, i_val2, i_val3;
    real r_val;
    string s_val;
    logic [31:0] h_val;

    initial begin
        $display("=== IEEE 1800-2023 Advanced Scanf Tests ===");

        // Test 1: Basic sscanf
        $display("Test 1: Basic integer sscanf");
        input_str = "42";
        count = $sscanf(input_str, "%d", i_val);
        if (count == 1 && i_val == 42) begin
            $display("Test 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: count=%0d, i_val=%0d", count, i_val);
            fail_count++;
        end

        // Test 2: Multiple integers
        $display("Test 2: Multiple integers");
        input_str = "10 20 30";
        count = $sscanf(input_str, "%d %d %d", i_val, i_val2, i_val3);
        if (count == 3 && i_val == 10 && i_val2 == 20 && i_val3 == 30) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: count=%0d", count);
            fail_count++;
        end

        // Test 3: Hex format
        $display("Test 3: Hexadecimal format");
        input_str = "CAFE";
        count = $sscanf(input_str, "%h", h_val);
        if (count == 1 && h_val == 32'hCAFE) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: h_val=%h", h_val);
            fail_count++;
        end

        // Test 4: Real number
        $display("Test 4: Real number");
        input_str = "3.14159";
        count = $sscanf(input_str, "%f", r_val);
        if (count == 1 && r_val > 3.14 && r_val < 3.15) begin
            $display("Test 4 PASS");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: r_val=%f", r_val);
            fail_count++;
        end

        // Test 5: String format
        $display("Test 5: String format");
        input_str = "Hello";
        count = $sscanf(input_str, "%s", s_val);
        if (count == 1 && s_val == "Hello") begin
            $display("Test 5 PASS");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: s_val=%s", s_val);
            fail_count++;
        end

        // Test 6: Mixed format
        $display("Test 6: Mixed int and hex");
        input_str = "100 FF";
        count = $sscanf(input_str, "%d %h", i_val, h_val);
        if (count == 2 && i_val == 100 && h_val == 32'hFF) begin
            $display("Test 6 PASS");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: With literal text
        $display("Test 7: Format with literal text");
        input_str = "value=123";
        count = $sscanf(input_str, "value=%d", i_val);
        if (count == 1 && i_val == 123) begin
            $display("Test 7 PASS");
            pass_count++;
        end else begin
            $display("Test 7 FAIL: count=%0d i_val=%0d", count, i_val);
            fail_count++;
        end

        // Test 8: Negative number
        $display("Test 8: Negative number");
        input_str = "-42";
        count = $sscanf(input_str, "%d", i_val);
        if (count == 1 && i_val == -42) begin
            $display("Test 8 PASS");
            pass_count++;
        end else begin
            $display("Test 8 FAIL: i_val=%0d", i_val);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
