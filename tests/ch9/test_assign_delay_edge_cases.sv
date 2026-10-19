/*
:name: test_assign_delay_edge_cases
:description: Test: Assignment delay edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 9.4.2 9.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_delay_edge_cases.expected
*/
// Test: Assignment delay edge cases
// IEEE 1800-2023 Section 10.4 Procedural Assignments
// Tests corner cases: assignment delays

`timescale 1ns/1ps

module test_assign_delay_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] data;
    logic clk = 0;
    logic [7:0] delayed;
    time t1, t2;

    initial repeat(100) #5 clk = ~clk;

    initial begin
        $display("TEST: Assignment delay edge cases");

        data = 0;
        delayed = 0;

        // Test 1: Intra-assignment delay
        begin
            t1 = $time;
            data = #5 8'hAB;
            t2 = $time;
            if (data == 8'hAB && (t2 - t1) == 5) begin
                $display("  [PASS] Intra-assignment delay");
                passed++;
            end else begin
                $display("  [FAIL] IntraDelay: %h %0d", data, t2-t1);
                failed++;
            end
        end

        // Test 2: Blocking with delay
        begin
            t1 = $time;
            #3 data = 8'h55;
            t2 = $time;
            if (data == 8'h55 && (t2 - t1) == 3) begin
                $display("  [PASS] Blocking with delay");
                passed++;
            end else begin
                $display("  [FAIL] BlockDelay: %h %0d", data, t2-t1);
                failed++;
            end
        end

        // Test 3: Sequential delays
        begin
            t1 = $time;
            #1 data = 1;
            #2 data = 2;
            #3 data = 3;
            t2 = $time;
            if (data == 3 && (t2 - t1) == 6) begin
                $display("  [PASS] Sequential delays");
                passed++;
            end else begin
                $display("  [FAIL] SeqDelay: %0d %0d", data, t2-t1);
                failed++;
            end
        end

        // Test 4: Zero delay
        begin
            data = 8'hFF;
            #0 data = 8'h00;
            if (data == 8'h00) begin
                $display("  [PASS] Zero delay");
                passed++;
            end else begin
                $display("  [FAIL] ZeroDelay: %h", data);
                failed++;
            end
        end

        // Test 5: Delay in loop
        begin
            t1 = $time;
            for (int i = 0; i < 5; i++) begin
                #1 data = i;
            end
            t2 = $time;
            if ((t2 - t1) == 5) begin
                $display("  [PASS] Delay in loop");
                passed++;
            end else begin
                $display("  [FAIL] LoopDelay: %0d", t2-t1);
                failed++;
            end
        end

        // Test 6: Wait for clock
        begin
            data = 8'hCC;
            @(posedge clk);
            data = 8'hDD;
            if (data == 8'hDD) begin
                $display("  [PASS] Wait for clock");
                passed++;
            end else begin
                $display("  [FAIL] WaitClk: %h", data);
                failed++;
            end
        end

        // Test 7: Multiple clock waits
        begin
            static int count = 0;
            repeat(3) begin
                @(posedge clk);
                count++;
            end
            if (count == 3) begin
                $display("  [PASS] Multiple clock waits");
                passed++;
            end else begin
                $display("  [FAIL] MultClk: %0d", count);
                failed++;
            end
        end

        // Test 8: Event delay
        begin
            t1 = $time;
            @(posedge clk);
            t2 = $time;
            if (t2 > t1) begin
                $display("  [PASS] Event delay");
                passed++;
            end else begin
                $display("  [FAIL] EvDelay: %0d %0d", t1, t2);
                failed++;
            end
        end

        // Test 9: Combined delays
        begin
            t1 = $time;
            #5;
            @(posedge clk);
            #5;
            t2 = $time;
            if (t2 > t1 + 10) begin
                $display("  [PASS] Combined delays");
                passed++;
            end else begin
                $display("  [FAIL] CombDelay: %0d", t2-t1);
                failed++;
            end
        end

        // Test 10: Repeat delay
        begin
            t1 = $time;
            repeat(4) #2;
            t2 = $time;
            if ((t2 - t1) == 8) begin
                $display("  [PASS] Repeat delay");
                passed++;
            end else begin
                $display("  [FAIL] RepDelay: %0d", t2-t1);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
