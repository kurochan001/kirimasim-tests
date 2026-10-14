/*
:name: test_sysfunc_onehot
:description: $onehot system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_onehot.expected
*/
// IEEE 1800-2023 §20.9: $onehot system function
module test_sysfunc_onehot;
    int pass_count = 0;
    int fail_count = 0;
    int result;
    logic [7:0] val;

    initial begin
        // Test 1: Single bit set
        val = 8'h08;
        result = $onehot(val);
        if (result == 1) begin
            $display("Test 1 PASS: onehot(08) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 2: Multiple bits set
        val = 8'h18;
        result = $onehot(val);
        if (result == 0) begin
            $display("Test 2 PASS: onehot(18) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 3: No bits set
        val = 8'h00;
        result = $onehot(val);
        if (result == 0) begin
            $display("Test 3 PASS: onehot(00) = %0d", result);
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
