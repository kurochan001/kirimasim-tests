/*
:name: test_sysfunc_countones
:description: $countones system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_countones.expected
*/
// IEEE 1800-2023 §20.9: $countones system function
module test_sysfunc_countones;
    int pass_count = 0;
    int fail_count = 0;
    int result;
    logic [7:0] val;

    initial begin
        // Test 1: All zeros
        val = 8'h00;
        result = $countones(val);
        if (result == 0) begin
            $display("Test 1 PASS: countones(00) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 2: Some ones
        val = 8'hAA;  // 10101010
        result = $countones(val);
        if (result == 4) begin
            $display("Test 2 PASS: countones(AA) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 3: All ones
        val = 8'hFF;
        result = $countones(val);
        if (result == 8) begin
            $display("Test 3 PASS: countones(FF) = %0d", result);
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
