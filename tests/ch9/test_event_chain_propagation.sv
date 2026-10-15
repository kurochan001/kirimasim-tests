/*
:name: test_event_chain_propagation
:description: A chain of always @(signal) blocks settles in one time slot (IEEE 1800-2023 Sections 9.4.2 and 4.4.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 4.4.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_chain_propagation.expected
*/
`timescale 1ns/1ps

module test_event_chain_propagation;
    logic a, b, c, d;

    // Create convergence scenario
    always @(a) b = ~a;
    always @(b) c = ~b;
    always @(c) d = ~c;


    initial begin
        // Start at time 1: at time 0 the always blocks may not be waiting yet
        // (4.7), and only a is written so that each stage sees a change.
        #1;
        a = 0;
        #1;
        a = 1;
        #1;

        // Check values converged
        if (b != 0) $display("FAIL: b");
        if (c != 1) $display("FAIL: c");
        if (d != 0) $display("FAIL: d");

        // More transitions
        repeat (5) begin
            a = ~a;
            #1;
        end

        // The number of times each always block runs depends on whether the
        // simulator merges changes in one time step (4.7), so it is not checked.
        if (b != 1 || c != 0 || d != 1) $display("FAIL: after toggles");
        $display("TEST PASSED");
        $finish;
    end
endmodule
