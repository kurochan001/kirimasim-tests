/*
:name: test_cast_byte
:description: Byte type casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_byte.expected
*/
// IEEE 1800-2023 §6.24: Byte type casts
module test_cast_byte;
    int pass_count = 0;
    int fail_count = 0;
    byte bval;
    int ival;

    initial begin
        // Test 1: Int to byte
        ival = 100;
        bval = byte'(ival);
        if (bval == 100) begin
            $display("Test 1 PASS: int to byte = %0d", bval);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", bval);
            fail_count++;
        end

        // Test 2: Truncation
        ival = 300;  // > 127
        bval = byte'(ival);  // keeps the low 8 bits, 8'h2C (6.24.1)
        if (bval == 44) begin
            $display("Test 2 PASS: truncate = %0d", bval);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: truncate = %0d (expected 44)", bval);
            fail_count++;
        end

        // Test 3: Negative byte
        ival = -50;
        bval = byte'(ival);
        if (bval == -50) begin
            $display("Test 3 PASS: negative = %0d", bval);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", bval);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
