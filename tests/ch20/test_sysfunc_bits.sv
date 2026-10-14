/*
:name: test_sysfunc_bits
:description: $bits system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_bits.expected
*/
// IEEE 1800-2023 §20.6: $bits system function
module test_sysfunc_bits;
    int pass_count = 0;
    int fail_count = 0;
    int result;
    logic [7:0] byte_val;
    logic [31:0] word_val;
    int int_val;

    initial begin
        // Test 1: Byte width
        result = $bits(byte_val);
        if (result == 8) begin
            $display("Test 1 PASS: bits(byte) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 2: Word width
        result = $bits(word_val);
        if (result == 32) begin
            $display("Test 2 PASS: bits(word) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 3: Int width
        result = $bits(int_val);
        if (result == 32) begin
            $display("Test 3 PASS: bits(int) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", result);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
