/*
:name: test_force_release_3
:description: Force/Release Test
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_release_3.expected
*/
// IEEE 1800-2023 §10.6 Force/Release Test

module test_force_release;
    reg [7:0] sig;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Force/Release Test (IEEE 1800-2023 §10.6) ===");

        // Test 1: Initial value
        sig = 8'hAA;
        if (sig == 8'hAA) begin
            $display("PASS: Initial sig = 0x%h", sig);
            passed++;
        end else begin
            $display("FAIL: Initial sig = 0x%h, expected 0xAA", sig);
            failed++;
        end

        // Test 2: Force to different value
        force sig = 8'h55;
        #1;  // The forced value is applied like a continuous assignment (10.6)
        if (sig == 8'h55) begin
            $display("PASS: Forced sig = 0x%h", sig);
            passed++;
        end else begin
            $display("FAIL: Forced sig = 0x%h, expected 0x55", sig);
            failed++;
        end

        // Test 3: Attempt to assign while forced (should be ignored)
        sig = 8'hFF;  // This assignment should be blocked by force
        if (sig == 8'h55) begin
            $display("PASS: Assign to forced signal ignored, sig = 0x%h", sig);
            passed++;
        end else begin
            $display("FAIL: Assign changed forced signal to 0x%h", sig);
            failed++;
        end

        // Test 4: Release and verify original behavior
        release sig;
        sig = 8'hBB;
        if (sig == 8'hBB) begin
            $display("PASS: After release, sig = 0x%h", sig);
            passed++;
        end else begin
            $display("FAIL: After release, sig = 0x%h, expected 0xBB", sig);
            failed++;
        end

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
