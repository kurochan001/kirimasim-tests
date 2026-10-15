/*
:name: test_cast_expr_2
:description: Casts between int, real, vector, enum and user-defined types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_expr_2.expected
*/
// Casts between int, real, vector, enum and user-defined types

module test_cast_expr;
    int pass_count = 0;
    int total_tests = 25;

    // Type definitions
    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;

    typedef enum {RED, GREEN, BLUE} color_e;

    // Test variables
    int i_val;
    real r_val;
    logic [31:0] l_val;
    logic signed [31:0] s_val;
    byte_t b_val;
    word_t w_val;
    color_e color;

    initial begin
        // Test 1: int to real cast
        i_val = 42;
        r_val = real'(i_val);
        if (r_val == 42.0) begin
            $display("Test 1 PASSED: real'(42) = 42.0");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: real to int cast (truncation)
        r_val = 3.7;
        i_val = int'(r_val);
        // Conversion of a real to an integer rounds to the nearest value (6.12.1).
        if (i_val == 4) begin
            $display("Test 2 PASSED: int'(3.7) = 4");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: real to int negative truncation
        r_val = -5.9;
        i_val = int'(r_val);
        if (i_val == -6) begin
            $display("Test 3 PASSED: int'(-5.9) = -6");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Signed to unsigned cast
        s_val = -1;
        l_val = 32'(s_val);
        if (l_val == 32'hFFFFFFFF) begin
            $display("Test 4 PASSED: unsigned'(-1) = 0xFFFFFFFF");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Unsigned to signed cast
        l_val = 32'hFFFFFFFF;
        s_val = signed'(l_val);
        if (s_val == -1) begin
            $display("Test 5 PASSED: signed'(0xFFFFFFFF) = -1");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Width reduction cast
        l_val = 32'h12345678;
        b_val = byte_t'(l_val);
        if (b_val == 8'h78) begin
            $display("Test 6 PASSED: byte_t'(0x12345678) = 0x78");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Width extension cast
        b_val = 8'hAB;
        l_val = dword_t'(b_val);
        if (l_val == 32'h000000AB) begin
            $display("Test 7 PASSED: dword_t'(0xAB) = 0x000000AB");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Enum to int cast
        color = GREEN;
        i_val = int'(color);
        if (i_val == 1) begin
            $display("Test 8 PASSED: int'(GREEN) = 1");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Int to enum cast
        i_val = 2;
        color = color_e'(i_val);
        if (color == BLUE) begin
            $display("Test 9 PASSED: color_e'(2) = BLUE");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Size cast
        b_val = 8'hFF;
        w_val = 16'(b_val);
        if (w_val == 16'h00FF) begin
            $display("Test 10 PASSED: 16'(8'hFF) = 16'h00FF");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Size cast with truncation
        l_val = 32'hABCD1234;
        w_val = 16'(l_val);
        if (w_val == 16'h1234) begin
            $display("Test 11 PASSED: 16'(0xABCD1234) = 0x1234");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Cast in expression
        i_val = 10;
        r_val = real'(i_val) / 4.0;
        if (r_val == 2.5) begin
            $display("Test 12 PASSED: real'(10) / 4.0 = 2.5");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Chained casts
        l_val = 32'hFFFF0001;
        b_val = byte_t'(word_t'(l_val));
        if (b_val == 8'h01) begin
            $display("Test 13 PASSED: byte_t'(word_t'(0xFFFF0001)) = 0x01");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Cast to same type (identity)
        i_val = 42;
        i_val = int'(i_val);
        if (i_val == 42) begin
            $display("Test 14 PASSED: int'(42) = 42");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Signed extension
        b_val = 8'h80;  // -128 as signed
        s_val = signed'({24'b0, b_val});
        if (s_val == 128) begin
            $display("Test 15 PASSED: unsigned extension = 128");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Bit-select result cast
        l_val = 32'hF0000000;
        if (int'(l_val[31]) == 1) begin
            $display("Test 16 PASSED: int'(l_val[31]) = 1");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Cast with literal
        r_val = real'(100);
        if (r_val == 100.0) begin
            $display("Test 17 PASSED: real'(100) = 100.0");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Cast negative to unsigned
        i_val = -10;
        l_val = 32'(i_val);
        if (l_val == 32'hFFFFFFF6) begin
            $display("Test 18 PASSED: 32'(-10) = 0xFFFFFFF6");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Cast 0 values
        i_val = 0;
        r_val = real'(i_val);
        if (r_val == 0.0) begin
            $display("Test 19 PASSED: real'(0) = 0.0");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Cast expression result
        i_val = int'(3 + 4);
        if (i_val == 7) begin
            $display("Test 20 PASSED: int'(3+4) = 7");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Size cast to 1 bit
        l_val = 32'h00000005;
        if (1'(l_val) == 1'b1) begin
            $display("Test 21 PASSED: 1'(5) = 1");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Size cast to 1 bit (even number)
        l_val = 32'h00000004;
        if (1'(l_val) == 1'b0) begin
            $display("Test 22 PASSED: 1'(4) = 0");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Cast real to shortreal behavior
        r_val = 1.5;
        if (real'(r_val) == 1.5) begin
            $display("Test 23 PASSED: real'(1.5) = 1.5");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Cast in conditional
        i_val = 1;
        r_val = i_val ? real'(10) : real'(20);
        if (r_val == 10.0) begin
            $display("Test 24 PASSED: conditional cast = 10.0");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Typedef cast chain
        b_val = 8'hCD;
        w_val = word_t'({8'hAB, b_val});
        if (w_val == 16'hABCD) begin
            $display("Test 25 PASSED: word_t'({0xAB, 0xCD}) = 0xABCD");
            pass_count++;
        end else $display("Test 25 FAILED");

        $display("PASS: cast_expr (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
