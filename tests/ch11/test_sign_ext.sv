/*
:name: test_sign_ext
:description: Sign Extension Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sign_ext.expected
*/
// IEEE 1800-2023 Section 11.8 - Sign Extension Tests
module test_sign_ext;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic signed [7:0] s8;
        logic signed [15:0] s16;
        logic [7:0] u8;
        logic [15:0] u16;
        int result;

        $display("=== IEEE 1800-2023 Sign Extension Tests ===");

        $display("Test 1: Positive extend");
        s8 = 8'sd127;
        s16 = s8;
        if (s16 == 16'sd127) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", s16); fail_count++; end

        $display("Test 2: Negative extend");
        s8 = -8'sd1;
        s16 = s8;
        if (s16 == -16'sd1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", s16); fail_count++; end

        $display("Test 3: Neg 128 extend");
        s8 = -8'sd128;
        s16 = s8;
        if (s16 == -16'sd128) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", s16); fail_count++; end

        $display("Test 4: Unsigned zero ext");
        u8 = 8'd255;
        u16 = u8;
        if (u16 == 16'd255) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", u16); fail_count++; end

        $display("Test 5: Signed to int");
        s8 = -8'sd50;
        result = s8;
        if (result == -50) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Unsigned to int");
        u8 = 8'd200;
        result = u8;
        if (result == 200) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Small neg");
        s8 = -8'sd10;
        s16 = s8;
        if (s16 == -16'sd10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", s16); fail_count++; end

        $display("Test 8: Zero extend");
        s8 = 8'sd0;
        s16 = s8;
        if (s16 == 16'sd0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", s16); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
