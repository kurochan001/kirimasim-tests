/*
:name: test_string_atobin
:description: Test: String atobin method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atobin.expected
*/
// Test: String atobin method
// IEEE 1800-2023 Section 6.16.9

module test_string_atobin;
    initial begin
        string s;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple binary value
        s = "1010";
        result = s.atobin();
        if (result == 4'b1010) begin
            $display("PASS: atobin('1010') = %0d (binary %b)", result, result);
            pass_count++;
        end else begin
            $display("FAIL: atobin('1010') expected 10, got %0d", result);
            fail_count++;
        end

        // Test 2: All ones
        s = "11111111";
        result = s.atobin();
        if (result == 8'b11111111) begin
            $display("PASS: atobin('11111111') = %0d (0x%0h)", result, result);
            pass_count++;
        end else begin
            $display("FAIL: atobin('11111111') expected 255, got %0d", result);
            fail_count++;
        end

        // Test 3: All zeros
        s = "0000";
        result = s.atobin();
        if (result == 0) begin
            $display("PASS: atobin('0000') = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: atobin('0000') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 4: Single bit
        s = "1";
        result = s.atobin();
        if (result == 1) begin
            $display("PASS: atobin('1') = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: atobin('1') expected 1, got %0d", result);
            fail_count++;
        end

        // Test 5: Mixed pattern
        s = "10110101";
        result = s.atobin();
        if (result == 8'b10110101) begin
            $display("PASS: atobin('10110101') = %0d (0x%0h)", result, result);
            pass_count++;
        end else begin
            $display("FAIL: atobin('10110101') expected 181, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string atobin tests passed");
        else
            $display("FAIL: Some string atobin tests failed");

        $finish;
    end
endmodule
