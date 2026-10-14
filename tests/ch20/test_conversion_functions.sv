/*
:name: test_conversion_functions
:description: Conversion Functions (§20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conversion_functions.expected
*/
// IEEE 1800-2023 Conversion Functions (§20.5)
// Tests $signed, $unsigned, $rtoi, $itor

module test_conversion_functions;
    initial begin
        logic [7:0] u_val;
        logic signed [7:0] s_val;
        real r_val;
        int i_val;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: $signed
        u_val = 8'hFF;  // 255 unsigned
        s_val = $signed(u_val);
        if (s_val == -1) begin
            $display("PASS: $signed(8'hFF) = %0d", s_val);
            pass_count++;
        end else begin
            $display("FAIL: $signed(8'hFF) = %0d, expected -1", s_val);
            fail_count++;
        end

        // Test 2: $unsigned
        s_val = -5;
        u_val = $unsigned(s_val);
        if (u_val == 8'hFB) begin
            $display("PASS: $unsigned(-5) = 0x%02X", u_val);
            pass_count++;
        end else begin
            $display("FAIL: $unsigned(-5) = 0x%02X, expected 0xFB", u_val);
            fail_count++;
        end

        // Test 3: $itor (integer to real)
        i_val = 42;
        r_val = $itor(i_val);
        if (r_val == 42.0) begin
            $display("PASS: $itor(42) = %0f", r_val);
            pass_count++;
        end else begin
            $display("FAIL: $itor(42) = %0f, expected 42.0", r_val);
            fail_count++;
        end

        // Test 4: $rtoi (real to integer)
        r_val = 3.7;
        i_val = $rtoi(r_val);
        if (i_val == 3) begin
            $display("PASS: $rtoi(3.7) = %0d (truncated)", i_val);
            pass_count++;
        end else begin
            $display("FAIL: $rtoi(3.7) = %0d, expected 3", i_val);
            fail_count++;
        end

        // Test 5: $rtoi with negative
        r_val = -2.9;
        i_val = $rtoi(r_val);
        if (i_val == -2) begin
            $display("PASS: $rtoi(-2.9) = %0d (truncated toward zero)", i_val);
            pass_count++;
        end else begin
            $display("FAIL: $rtoi(-2.9) = %0d, expected -2", i_val);
            fail_count++;
        end

        // Test 6: Cast real to int
        r_val = 5.9;
        i_val = int'(r_val);
        if (i_val == 6) begin
            $display("PASS: int'(5.9) = %0d (rounded)", i_val);
            pass_count++;
        end else begin
            $display("FAIL: int'(5.9) = %0d, expected 6", i_val);
            fail_count++;
        end

        $display("");
        $display("=== Conversion Functions Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $fatal(1, "TEST FAILED");

        $finish;
    end
endmodule
