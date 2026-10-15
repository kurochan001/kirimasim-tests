/*
:name: test_force_nested
:description: force sequences
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_nested.expected
*/
// IEEE 1800-2023 §10.6.2: force sequences
module test_force_nested;
    logic [7:0] sig1, sig2, sig3;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Force multiple signals
        sig1 = 8'h00;
        sig2 = 8'h00;
        sig3 = 8'h00;
        force sig1 = 8'hAA;
        force sig2 = 8'hBB;
        force sig3 = 8'hCC;
        #1;
        if (sig1 == 8'hAA && sig2 == 8'hBB && sig3 == 8'hCC) begin
            $display("Test 1 PASS: multiple forces");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: sig1=%02h sig2=%02h sig3=%02h", sig1, sig2, sig3);
            fail_count++;
        end

        // Test 2: Release all
        release sig1;
        release sig2;
        release sig3;
        sig1 = 8'h11;
        sig2 = 8'h22;
        sig3 = 8'h33;
        #1;
        if (sig1 == 8'h11 && sig2 == 8'h22 && sig3 == 8'h33) begin
            $display("Test 2 PASS: released all");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: sig1=%02h sig2=%02h sig3=%02h", sig1, sig2, sig3);
            fail_count++;
        end

        // Test 3: Interleaved force/release
        force sig1 = 8'hDD;
        #1;
        release sig1;
        force sig2 = 8'hEE;
        #1;
        if (sig2 == 8'hEE) begin
            $display("Test 3 PASS: interleaved force");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: sig2=%02h", sig2);
            fail_count++;
        end
        release sig2;

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
