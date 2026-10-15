/*
:name: test_event_named
:description: Test: Named events
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5 15.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_named.expected
*/
// Test: Named events
// Verifies named event declaration and usage

module test_event_named;
    event evt1;
    event evt2;
    event evt_array[3];
    int evt1_triggered = 0;
    int evt2_triggered = 0;
    int evt_array_triggered[3];
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: Wait for evt1
    initial begin
        @(evt1);
        evt1_triggered = 1;
    end

    // Scenario 2: Wait for evt2
    initial begin
        @(evt2);
        evt2_triggered = 1;
    end

    // Scenario 3: Wait for array events
    initial begin
        @(evt_array[0]);
        evt_array_triggered[0] = 1;
    end

    initial begin
        @(evt_array[1]);
        evt_array_triggered[1] = 1;
    end

    initial begin
        @(evt_array[2]);
        evt_array_triggered[2] = 1;
    end

    // Main test
    initial begin
        // Initialize
        evt_array_triggered[0] = 0;
        evt_array_triggered[1] = 0;
        evt_array_triggered[2] = 0;

        #1;

        // Test 1: Events not triggered yet
        if (evt1_triggered == 0 && evt2_triggered == 0) begin
            $display("PASS: Scenario 1 - Events initially not triggered");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - Events triggered prematurely");
            fail_count++;
        end

        // Test 2: Trigger evt1
        -> evt1;
        #1;
        if (evt1_triggered == 1) begin
            $display("PASS: Scenario 2 - evt1 triggered");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - evt1 not triggered");
            fail_count++;
        end

        // Test 3: evt2 still not triggered
        if (evt2_triggered == 0) begin
            $display("PASS: Scenario 3 - evt2 still waiting");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - evt2 triggered unexpectedly");
            fail_count++;
        end

        // Test 4: Trigger evt2
        -> evt2;
        #1;
        if (evt2_triggered == 1) begin
            $display("PASS: Scenario 4 - evt2 triggered");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - evt2 not triggered");
            fail_count++;
        end

        // Test 5: Trigger array events
        -> evt_array[0];
        #1;
        if (evt_array_triggered[0] == 1) begin
            $display("PASS: Scenario 5a - evt_array[0] triggered");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5a - evt_array[0] not triggered");
            fail_count++;
        end

        -> evt_array[1];
        -> evt_array[2];
        #1;
        if (evt_array_triggered[1] == 1 && evt_array_triggered[2] == 1) begin
            $display("PASS: Scenario 5b - evt_array[1,2] triggered");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5b - Array events not all triggered");
            fail_count++;
        end

        // Summary
        $display("Named events: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
