/*
:name: test_cast_real_2
:description: Casts of integral and shortreal values to real
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_real_2.expected
*/
// Casts of integral and shortreal values to real

module test_cast_real;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    int i_val;
    shortint si_val;
    longint li_val;
    bit [31:0] b_val;
    logic [63:0] l_val;
    byte by_val;
    shortreal sr_val;

    real result;
    real epsilon = 0.0001;

    function bit real_eq(real a, real b);
        real diff;
        diff = a - b;
        if (diff < 0) diff = -diff;
        return diff < epsilon;
    endfunction

    initial begin
        // Test 1: int to real
        total_tests++;
        i_val = 42;
        result = real'(i_val);
        if (real_eq(result, 42.0)) begin
            pass_count++;
            $display("PASS: int to real");
        end else $display("FAIL: int to real, got %f", result);

        // Test 2: negative int to real
        total_tests++;
        i_val = -1000;
        result = real'(i_val);
        if (real_eq(result, -1000.0)) begin
            pass_count++;
            $display("PASS: negative int to real");
        end else $display("FAIL: negative int to real, got %f", result);

        // Test 3: shortint to real
        total_tests++;
        si_val = 32767;
        result = real'(si_val);
        if (real_eq(result, 32767.0)) begin
            pass_count++;
            $display("PASS: shortint to real");
        end else $display("FAIL: shortint to real, got %f", result);

        // Test 4: longint to real
        total_tests++;
        li_val = 64'h0000_0000_7FFF_FFFF;
        result = real'(li_val);
        if (real_eq(result, 2147483647.0)) begin
            pass_count++;
            $display("PASS: longint to real");
        end else $display("FAIL: longint to real, got %f", result);

        // Test 5: bit vector to real
        total_tests++;
        b_val = 32'd12345;
        result = real'(b_val);
        if (real_eq(result, 12345.0)) begin
            pass_count++;
            $display("PASS: bit vector to real");
        end else $display("FAIL: bit vector to real, got %f", result);

        // Test 6: logic vector to real
        total_tests++;
        l_val = 64'd9876543210;
        result = real'(l_val);
        if (result > 9876543000.0 && result < 9876544000.0) begin
            pass_count++;
            $display("PASS: logic vector to real");
        end else $display("FAIL: logic vector to real, got %f", result);

        // Test 7: byte to real
        total_tests++;
        by_val = -128;
        result = real'(by_val);
        if (real_eq(result, -128.0)) begin
            pass_count++;
            $display("PASS: byte to real");
        end else $display("FAIL: byte to real, got %f", result);

        // Test 8: shortreal to real
        total_tests++;
        sr_val = 3.14159;
        result = real'(sr_val);
        if (result > 3.14 && result < 3.15) begin
            pass_count++;
            $display("PASS: shortreal to real");
        end else $display("FAIL: shortreal to real, got %f", result);

        // Test 9: zero to real
        total_tests++;
        i_val = 0;
        result = real'(i_val);
        if (real_eq(result, 0.0)) begin
            pass_count++;
            $display("PASS: zero to real");
        end else $display("FAIL: zero to real, got %f", result);

        // Test 10: large positive value
        total_tests++;
        li_val = 64'd1000000000000;
        result = real'(li_val);
        if (result > 999999999999.0 && result < 1000000000001.0) begin
            pass_count++;
            $display("PASS: large value to real");
        end else $display("FAIL: large value to real, got %f", result);

        // Test 11: real to real (identity)
        total_tests++;
        result = real'(2.71828);
        if (result > 2.71 && result < 2.72) begin
            pass_count++;
            $display("PASS: real to real");
        end else $display("FAIL: real to real, got %f", result);

        // Test 12: unsigned bit to real
        total_tests++;
        b_val = 32'hFFFF_FFFF;
        result = real'(b_val);
        if (result > 4294967294.0) begin
            pass_count++;
            $display("PASS: unsigned max to real");
        end else $display("FAIL: unsigned max to real, got %f", result);

        $display("PASS: cast_real (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
