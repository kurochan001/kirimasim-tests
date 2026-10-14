/*
:name: test_sysfunc_clog2
:description: $clog2 system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_clog2.expected
*/
// IEEE 1800-2023 §20.8.1: $clog2 system function
module test_sysfunc_clog2;
    int pass_count = 0;
    int fail_count = 0;
    int result;

    initial begin
        // Test 1: Power of 2
        result = $clog2(8);
        if (result == 3) begin
            $display("Test 1 PASS: clog2(8) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 2: Non-power of 2
        result = $clog2(10);
        if (result == 4) begin
            $display("Test 2 PASS: clog2(10) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 3: Large value
        result = $clog2(256);
        if (result == 8) begin
            $display("Test 3 PASS: clog2(256) = %0d", result);
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
