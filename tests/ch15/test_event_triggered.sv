/*
:name: test_event_triggered
:description: Test: Event triggered method
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_triggered.expected
*/
// Test: Event triggered method
// IEEE 1800-2023 Section 15.5.3

module test_event_triggered;
    event e1, e2, e3;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Event not triggered initially
        if (!e1.triggered) begin
            $display("PASS: Event e1 not triggered initially");
            pass_count++;
        end else begin
            $display("FAIL: Event e1 should not be triggered initially");
            fail_count++;
        end

        // Test 2: Check triggered after trigger
        -> e1;
        if (e1.triggered) begin
            $display("PASS: Event e1 is triggered after ->");
            pass_count++;
        end else begin
            $display("FAIL: Event e1 should be triggered after ->");
            fail_count++;
        end

        // Test 3: Check another event (not triggered)
        if (!e2.triggered) begin
            $display("PASS: Event e2 is not triggered");
            pass_count++;
        end else begin
            $display("FAIL: Event e2 should not be triggered");
            fail_count++;
        end

        // Test 4: Trigger second event
        -> e2;
        if (e2.triggered) begin
            $display("PASS: Event e2 is now triggered");
            pass_count++;
        end else begin
            $display("FAIL: Event e2 should be triggered now");
            fail_count++;
        end

        // Test 5: Both events triggered
        if (e1.triggered && e2.triggered && !e3.triggered) begin
            $display("PASS: e1 and e2 triggered, e3 not triggered");
            pass_count++;
        end else begin
            $display("FAIL: Event triggered states incorrect");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All event triggered tests passed");
        else
            $display("FAIL: Some event triggered tests failed");

        $finish;
    end
endmodule
