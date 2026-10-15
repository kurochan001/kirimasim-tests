/*
:name: test_cast_signed
:description: Signed/unsigned casts
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_signed.expected
*/
// IEEE 1800-2023 §6.24: Signed/unsigned casts
module test_cast_signed;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] uval;
    logic signed [7:0] sval;

    initial begin
        // Test 1: Unsigned to signed
        uval = 8'hFF;  // 255 unsigned
        sval = $signed(uval);
        if (sval == -1) begin
            $display("Test 1 PASS: unsigned to signed = %0d", sval);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", sval);
            fail_count++;
        end

        // Test 2: Signed to unsigned
        sval = -1;
        uval = $unsigned(sval);
        if (uval == 8'hFF) begin
            $display("Test 2 PASS: signed to unsigned = %02h", uval);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", uval);
            fail_count++;
        end

        // Test 3: Positive value (same either way)
        uval = 8'd100;
        sval = $signed(uval);
        if (sval == 100) begin
            $display("Test 3 PASS: positive stays same = %0d", sval);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", sval);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
