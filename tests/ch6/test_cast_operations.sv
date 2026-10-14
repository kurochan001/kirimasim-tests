/*
:name: test_cast_operations
:description: Cast Operations Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_operations.expected
*/
// IEEE 1800-2023 Section 6.24 - Cast Operations Tests
// Tests: $cast, type casting, signed/unsigned casts

module test_cast_operations;
    int pass_count = 0;
    int fail_count = 0;

    int i_val;
    real r_val;
    logic [31:0] l_val;
    logic signed [31:0] s_val;
    bit [7:0] b_val;
    shortint si_val;
    longint li_val;
    int success;

    initial begin
        $display("=== IEEE 1800-2023 Cast Operations Tests ===");

        // Test 1: int to real
        $display("Test 1: int to real");
        i_val = 42;
        r_val = real'(i_val);
        if (r_val == 42.0) begin
            $display("Test 1 PASS: r_val=%f", r_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: real to int (rounds to nearest per §6.12.1)
        $display("Test 2: real to int");
        r_val = 3.7;
        i_val = int'(r_val);
        if (i_val == 4) begin
            $display("Test 2 PASS: i_val=%0d", i_val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: i_val=%0d", i_val);
            fail_count++;
        end

        // Test 3: unsigned to signed
        $display("Test 3: unsigned to signed");
        l_val = 32'hFFFFFFFF;
        s_val = signed'(l_val);
        if (s_val == -1) begin
            $display("Test 3 PASS: s_val=%0d", s_val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: s_val=%0d", s_val);
            fail_count++;
        end

        // Test 4: signed to unsigned
        $display("Test 4: signed to unsigned");
        s_val = -1;
        l_val = unsigned'(s_val);
        if (l_val == 32'hFFFFFFFF) begin
            $display("Test 4 PASS: l_val=%h", l_val);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: l_val=%h", l_val);
            fail_count++;
        end

        // Test 5: Size casting (truncation)
        $display("Test 5: Size casting truncation");
        i_val = 32'h12345678;
        b_val = 8'(i_val);
        if (b_val == 8'h78) begin
            $display("Test 5 PASS: b_val=%h", b_val);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: b_val=%h", b_val);
            fail_count++;
        end

        // Test 6: Size casting (extension)
        $display("Test 6: Size casting extension");
        b_val = 8'hAB;
        i_val = int'(b_val);
        if (i_val == 32'h000000AB) begin
            $display("Test 6 PASS: i_val=%h", i_val);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: i_val=%h", i_val);
            fail_count++;
        end

        // Test 7: shortint cast
        $display("Test 7: shortint cast");
        i_val = 1000;
        si_val = shortint'(i_val);
        if (si_val == 1000) begin
            $display("Test 7 PASS: si_val=%0d", si_val);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: longint cast
        $display("Test 8: longint cast");
        i_val = 123456;
        li_val = longint'(i_val);
        if (li_val == 123456) begin
            $display("Test 8 PASS: li_val=%0d", li_val);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
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
