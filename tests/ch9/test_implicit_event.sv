/*
:name: test_implicit_event
:description: Test for @* (implicit event control) - IEEE 1800-2023 §9.4.2.2
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_event.expected
*/
// Test for @* (implicit event control) - IEEE 1800-2023 §9.4.2.2
// This tests that always @* blocks correctly trigger on any signal change

module test_implicit_event;
    logic a, b, c;
    logic y_comb;
    int trigger_count;

    // Combinational logic using @*
    always @* begin
        y_comb = a & b | c;
        trigger_count = trigger_count + 1;
    end

    initial begin
        static int passed = 0;
        static int failed = 0;

        $display("=== Implicit Event Control @* Test (IEEE 1800-2023 §9.4.2.2) ===");

        // Initialize at time 1: at time 0 the always @* block may not be
        // waiting yet, since the order of the processes is not defined (4.7).
        #1;
        a = 0;
        b = 0;
        c = 0;
        #1;

        // Test 1: Initial execution should happen
        if (y_comb == 0 && trigger_count >= 1) begin
            $display("PASS: Initial y_comb = %b", y_comb);
            passed++;
        end else begin
            $display("FAIL: Initial y_comb = %b, trigger_count=%0d", y_comb, trigger_count);
            failed++;
        end

        // Test 2: Change 'a' should trigger re-evaluation
        #1;
        a = 1;
        #1;
        if (y_comb == 0) begin  // a=1, b=0, c=0 -> 0 & 0 | 0 = 0
            $display("PASS: After a=1, y_comb = %b", y_comb);
            passed++;
        end else begin
            $display("FAIL: After a=1, y_comb = %b, expected 0", y_comb);
            failed++;
        end

        // Test 3: Change 'b' should trigger re-evaluation
        b = 1;
        #1;
        if (y_comb == 1) begin  // a=1, b=1, c=0 -> 1 & 1 | 0 = 1
            $display("PASS: After b=1, y_comb = %b", y_comb);
            passed++;
        end else begin
            $display("FAIL: After b=1, y_comb = %b, expected 1", y_comb);
            failed++;
        end

        // Test 4: Change 'c' should trigger re-evaluation
        a = 0;
        b = 0;
        c = 1;
        #1;
        if (y_comb == 1) begin  // a=0, b=0, c=1 -> 0 & 0 | 1 = 1
            $display("PASS: After c=1, y_comb = %b", y_comb);
            passed++;
        end else begin
            $display("FAIL: After c=1, y_comb = %b, expected 1", y_comb);
            failed++;
        end

        // Test 5: No change should not increase trigger_count significantly
        // (This is hard to test precisely without knowing exact scheduling)

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);
        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
