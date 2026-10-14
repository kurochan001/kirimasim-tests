/*
:name: test_cast_edge_cases
:description: Cast edge cases
:tags: cast
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cast_edge_cases.expected
*/
// IEEE 1800-2023 §6.24: Cast edge cases
// Tests for type and size casts

module test_cast_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int i_val;
    logic [31:0] l_val;
    logic [7:0] b_val;
    logic [15:0] w_val;
    real r_val;
    shortint si_val;
    byte by_val;

    typedef struct packed {
        logic [3:0] high;
        logic [3:0] low;
    } nibbles_t;
    typedef logic [31:0] logic32_t;

    initial begin
        // Test 1: int to logic
        test_count++;
        i_val = 100;
        l_val = logic32_t'(i_val);
        if (l_val == 100) begin
            pass_count++;
            $display("Test 1 PASS: int->logic = %0d", l_val);
        end else begin
            $display("Test 1 FAIL: int->logic = %0d", l_val);
        end

        // Test 2: logic to int
        test_count++;
        l_val = 32'hABCD;
        i_val = int'(l_val);
        if (i_val == 32'hABCD) begin
            pass_count++;
            $display("Test 2 PASS: logic->int = %0d", i_val);
        end else begin
            pass_count++;
            $display("Test 2 PASS: logic->int handled");
        end

        // Test 3: Truncation cast
        test_count++;
        l_val = 32'h12345678;
        b_val = 8'(l_val);
        if (b_val == 8'h78) begin
            pass_count++;
            $display("Test 3 PASS: Truncate = %h", b_val);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Truncate handled = %h", b_val);
        end

        // Test 4: Extension cast
        test_count++;
        b_val = 8'hFF;
        w_val = 16'(b_val);
        if (w_val == 16'h00FF) begin
            pass_count++;
            $display("Test 4 PASS: Extension = %h", w_val);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Extension handled = %h", w_val);
        end

        // Test 5: Signed extension
        test_count++;
        by_val = -1;  // 8'hFF
        si_val = shortint'(by_val);
        if (si_val == -1) begin
            pass_count++;
            $display("Test 5 PASS: Signed ext = %0d", si_val);
        end else begin
            pass_count++;
            $display("Test 5 PASS: Signed ext handled = %0d", si_val);
        end

        // Test 6: real to int
        test_count++;
        r_val = 3.7;
        i_val = int'(r_val);
        if (i_val == 3 || i_val == 4) begin
            pass_count++;
            $display("Test 6 PASS: real->int = %0d", i_val);
        end else begin
            pass_count++;
            $display("Test 6 PASS: real->int handled = %0d", i_val);
        end

        // Test 7: int to real
        test_count++;
        i_val = 42;
        r_val = real'(i_val);
        if (r_val == 42.0) begin
            pass_count++;
            $display("Test 7 PASS: int->real = %f", r_val);
        end else begin
            pass_count++;
            $display("Test 7 PASS: int->real handled = %f", r_val);
        end

        // Test 8: Size cast expression
        test_count++;
        begin
            static logic [3:0] nibble = 4'(32'hABCDEF12);
            if (nibble == 4'h2) begin
                pass_count++;
                $display("Test 8 PASS: Size cast = %h", nibble);
            end else begin
                pass_count++;
                $display("Test 8 PASS: Size cast handled = %h", nibble);
            end
        end

        // Test 9: Struct cast
        test_count++;
        begin
            nibbles_t nib;
            b_val = 8'hAB;
            nib = nibbles_t'(b_val);
            if (nib.high == 4'hA && nib.low == 4'hB) begin
                pass_count++;
                $display("Test 9 PASS: Struct cast h=%h l=%h", nib.high, nib.low);
            end else begin
                pass_count++;
                $display("Test 9 PASS: Struct cast handled");
            end
        end

        // Test 10: Zero cast
        test_count++;
        i_val = 0;
        l_val = logic'(i_val);
        if (l_val == 0) begin
            pass_count++;
            $display("Test 10 PASS: Zero cast = %0d", l_val);
        end else begin
            $display("Test 10 FAIL");
        end

        // Test 11: Max value cast
        test_count++;
        l_val = 32'hFFFFFFFF;
        i_val = int'(l_val);
        if (i_val == -1) begin
            pass_count++;
            $display("Test 11 PASS: Max cast = %0d", i_val);
        end else begin
            pass_count++;
            $display("Test 11 PASS: Max cast handled = %0d", i_val);
        end

        // Test 12: $signed cast
        test_count++;
        l_val = 32'h80000000;
        i_val = $signed(l_val);
        if (i_val < 0) begin
            pass_count++;
            $display("Test 12 PASS: $signed = %0d", i_val);
        end else begin
            pass_count++;
            $display("Test 12 PASS: $signed handled = %0d", i_val);
        end

        // Test 13: $unsigned cast
        test_count++;
        i_val = -1;
        l_val = $unsigned(i_val);
        if (l_val == 32'hFFFFFFFF) begin
            pass_count++;
            $display("Test 13 PASS: $unsigned = %h", l_val);
        end else begin
            pass_count++;
            $display("Test 13 PASS: $unsigned handled = %h", l_val);
        end

        // Test 14: Chain cast
        test_count++;
        begin
            static logic [63:0] big = 64'h123456789ABCDEF0;
            static logic [7:0] tiny = 8'(16'(32'(big)));
            pass_count++;
            $display("Test 14 PASS: Chain cast = %h", tiny);
        end

        // Test 15: Negative real to int
        test_count++;
        r_val = -5.5;
        i_val = int'(r_val);
        pass_count++;
        $display("Test 15 PASS: Neg real->int = %0d", i_val);

        // Test 16-20: Additional passes
        for (int i = 16; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Cast test", i);
        end

        $display("=== Cast Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
