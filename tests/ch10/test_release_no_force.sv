/*
:name: test_release_no_force
:description: release without prior force
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_release_no_force.expected
*/
// IEEE 1800-2023 §10.6.2: release without prior force
module test_release_no_force;
    logic [7:0] sig;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Release without force should be no-op
        sig = 8'hAB;
        release sig;  // Should be no-op
        #1;
        if (sig == 8'hAB) begin
            $display("Test 1 PASS: release no-op, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", sig);
            fail_count++;
        end

        // Test 2: Assignment works after no-op release
        sig = 8'hCD;
        #1;
        if (sig == 8'hCD) begin
            $display("Test 2 PASS: assign works, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", sig);
            fail_count++;
        end

        // Test 3: Double release is no-op
        force sig = 8'hEF;
        #1;
        release sig;
        release sig;  // Double release should be no-op
        sig = 8'h12;
        #1;
        if (sig == 8'h12) begin
            $display("Test 3 PASS: double release ok, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", sig);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
