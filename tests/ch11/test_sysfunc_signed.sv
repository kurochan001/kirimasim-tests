/*
:name: test_sysfunc_signed
:description: $signed system function
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_signed.expected
*/
// IEEE 1800-2023 §11.7: $signed system function
module test_sysfunc_signed;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] unsigned_val;
    int signed_result;

    initial begin
        // Test 1: Positive value
        unsigned_val = 8'h7F;  // 127
        signed_result = $signed(unsigned_val);
        if (signed_result == 127) begin
            $display("Test 1 PASS: signed(7F) = %0d", signed_result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", signed_result);
            fail_count++;
        end

        // Test 2: Value with MSB set (becomes negative)
        unsigned_val = 8'hFF;  // -1 as signed
        signed_result = $signed(unsigned_val);
        if (signed_result == -1) begin
            $display("Test 2 PASS: signed(FF) = %0d", signed_result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", signed_result);
            fail_count++;
        end

        // Test 3: Zero
        unsigned_val = 8'h00;
        signed_result = $signed(unsigned_val);
        if (signed_result == 0) begin
            $display("Test 3 PASS: signed(00) = %0d", signed_result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", signed_result);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
