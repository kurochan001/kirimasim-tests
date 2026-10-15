/*
:name: test_monitor_strobe
:description: Display System Tasks
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.2 21.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_monitor_strobe.expected
*/
// IEEE 1800-2023 §21.2 Display System Tasks
// Tests $monitor, $strobe, $monitoron, $monitoroff

`timescale 1ns/1ps

module test_monitor_strobe;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic [7:0] counter;

    // Generate clock
    initial begin
        repeat (20) begin
            #5 clk = ~clk;
        end
    end

    initial begin
        counter = 8'd0;

        // Test 1: Basic $monitor
        $monitor("Monitor: time=%0t, counter=%0d", $time, counter);
        $display("PASS: $monitor set up");
        pass_count++;

        // Test 2: Value change triggers monitor
        @(posedge clk);
        counter = 8'd1;
        @(posedge clk);
        counter = 8'd2;
        @(posedge clk);
        $display("PASS: Monitor triggered on counter changes");
        pass_count++;

        // Test 3: $monitoroff - disable monitoring
        $monitoroff;
        @(posedge clk);
        counter = 8'd10;  // Should not be monitored
        @(posedge clk);
        counter = 8'd20;  // Should not be monitored
        $display("PASS: $monitoroff called");
        pass_count++;

        // Test 4: $monitoron - re-enable monitoring
        $monitoron;
        @(posedge clk);
        counter = 8'd30;  // Should be monitored
        @(posedge clk);
        $display("PASS: $monitoron called");
        pass_count++;

        // Test 5: $strobe - display at end of time step. The monitor is turned
        // off first: $monitor and $strobe both print in the Postponed region,
        // in no defined order (4.7).
        $monitoroff;
        counter = 8'd100;
        $strobe("Strobe: counter=%0d (at end of time step)", counter);
        counter = 8'd101;  // This value should be shown
        $display("PASS: $strobe scheduled");
        pass_count++;

        @(posedge clk);

        // Test 6: Strobe at a later time
        $strobe("Strobe: t=%0t", $time);
        $display("PASS: $strobe at a later time");
        pass_count++;

        @(posedge clk);

        $display("");
        $display("=== Monitor/Strobe Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
