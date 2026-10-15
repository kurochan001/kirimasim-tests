/*
:name: test_sysfunc_unsigned
:description: $unsigned system function
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_unsigned.expected
*/
// IEEE 1800-2023 §11.7: $unsigned system function
module test_sysfunc_unsigned;
    int pass_count = 0;
    int fail_count = 0;
    int signed_val;
    logic [31:0] unsigned_result;

    initial begin
        // Test 1: Positive value
        signed_val = 100;
        unsigned_result = $unsigned(signed_val);
        if (unsigned_result == 100) begin
            $display("Test 1 PASS: unsigned(100) = %0d", unsigned_result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", unsigned_result);
            fail_count++;
        end

        // Test 2: Negative value
        signed_val = -1;
        unsigned_result = $unsigned(signed_val);
        if (unsigned_result == 32'hFFFFFFFF) begin
            $display("Test 2 PASS: unsigned(-1) = %0h", unsigned_result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0h", unsigned_result);
            fail_count++;
        end

        // Test 3: Zero
        signed_val = 0;
        unsigned_result = $unsigned(signed_val);
        if (unsigned_result == 0) begin
            $display("Test 3 PASS: unsigned(0) = %0d", unsigned_result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", unsigned_result);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
