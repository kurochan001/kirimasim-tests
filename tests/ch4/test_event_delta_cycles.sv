/*
:name: test_event_delta_cycles
:description: Continuous assignments, event controls, #0 and nonblocking assignments within a time step
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.3 4.7 9.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_delta_cycles.expected
*/
// Continuous assignments, event controls, #0 and nonblocking assignments within a time step
module test_event_delta_cycles;
    logic a, b, c, d;
    // Initialized in the declaration, before time 0, so that no always block
    // sees a change of counter at time 0.
    logic [7:0] counter = 0;
    logic [7:0] delayed_counter = 0;
    logic pulse;
    int errors;

    // Chain of combinational assignments (delta cycle chain)
    wire not_a = ~a;
    wire ab = a & b;
    wire abc = ab & c;
    wire final_out = abc | d;

    // NBA vs blocking test
    logic [3:0] blocking_val;
    logic [3:0] nba_val;

    // Delta cycle counter
    always @(a or b or c) begin
        counter = counter + 1;
    end

    // One-cycle delayed value
    always @(counter) begin
        #0 delayed_counter = counter;  // Delta delay
    end

    initial begin
        errors = 0;

        // Initialize
        blocking_val = 0;
        nba_val = 0;

        // Change a, b and c only after time 0, when the always blocks are
        // surely waiting on them; at time 0 the order of the initial and
        // always procedures is not defined (4.7, 9.2.2).
        #1;
        a = 0;
        b = 0;
        c = 0;
        d = 0;
        #1;

        // Test 1: Combinational chain propagation
        $display("Test 1: Combinational chain propagation");
        a = 1;
        #0;  // Delta cycle
        if (not_a !== 0) begin
            $display("  FAIL: not_a should be 0, got %b", not_a);
            errors++;
        end else begin
            $display("  PASS: not_a = %b", not_a);
        end

        // Test 2: Multi-input chain
        $display("Test 2: Multi-input chain");
        b = 1;
        c = 1;
        #0;
        if (abc !== 1) begin
            $display("  FAIL: abc should be 1, got %b", abc);
            errors++;
        end else begin
            $display("  PASS: abc = %b", abc);
        end

        // Test 3: Delta cycle counter
        $display("Test 3: Delta cycle sensitivity");
        $display("  Counter before changes: %d", counter);
        a = 0;
        #0;
        a = 1;
        #0;
        a = 0;
        #0;
        $display("  Counter after 3 a changes: %d", counter);

        // Test 4: Simultaneous updates
        $display("Test 4: Simultaneous signal updates");
        a = 1;
        b = 0;
        c = 1;
        d = 0;
        #0;
        $display("  After simultaneous update: abc=%b, final=%b", abc, final_out);

        // Test 5: Blocking vs NBA in same time slot
        $display("Test 5: Blocking vs NBA ordering");
        blocking_val = 4'hA;
        nba_val <= 4'hB;
        $display("  Immediate blocking: %h, nba: %h", blocking_val, nba_val);
        #0;
        $display("  After delta - blocking: %h, nba: %h", blocking_val, nba_val);
        #1;
        $display("  After time advance - blocking: %h, nba: %h", blocking_val, nba_val);

        // Test 6: Delta delay propagation
        $display("Test 6: Delta delay in always block");
        a = 0;
        b = 0;
        // After #0 both this process and the #0 in the always block are in the
        // Inactive region, in no defined order (4.7); wait a time step instead.
        #1;
        $display("  Counter=%d, delayed_counter=%d", counter, delayed_counter);

        // Test 7: Multiple delta cycles in sequence
        $display("Test 7: Multiple delta cycles");
        for (int i = 0; i < 5; i++) begin
            a = ~a;
            #0;
        end
        $display("  After 5 toggles: a=%b, counter=%d", a, counter);

        // Test 8: Chain reaction
        $display("Test 8: Chain reaction through combinational logic");
        a = 0; b = 0; c = 0; d = 0;
        #0;
        $display("  Initial: final_out=%b", final_out);
        d = 1;
        #0;
        $display("  After d=1: final_out=%b (should be 1)", final_out);
        d = 0;
        a = 1; b = 1; c = 1;
        #0;
        $display("  After abc all 1: final_out=%b (should be 1)", final_out);

        $display("");
        if (errors == 0) begin
            $display("TEST PASSED: Event delta cycle tests completed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
