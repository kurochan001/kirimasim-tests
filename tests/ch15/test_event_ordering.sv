/*
:name: test_event_ordering
:description: Chapter 4: Scheduling semantics
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 9.4.2 4.4.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_ordering.expected
*/
// IEEE 1800-2023 Chapter 4: Scheduling semantics
// §4.3 Event model and §4.4 Stratified event queue

`timescale 1ns/1ps

module test_event_ordering;
    // Test event triggering and ordering

    reg clk;
    event ev1, ev2, ev3;
    int order_tracker;
    int expected_order;

    int test_count;
    int pass_count;

    // Process 1: triggers ev1
    always @(posedge clk) begin
        -> ev1;
    end

    // Process 2: waits for ev1, then triggers ev2
    always @(ev1) begin
        order_tracker = order_tracker * 10 + 1;
        -> ev2;
    end

    // Process 3: waits for ev2, then triggers ev3
    always @(ev2) begin
        order_tracker = order_tracker * 10 + 2;
        -> ev3;
    end

    // Process 4: waits for ev3
    always @(ev3) begin
        order_tracker = order_tracker * 10 + 3;
    end

    initial begin
        test_count = 0;
        pass_count = 0;
        clk = 0;
        order_tracker = 0;

        // Test 1: Event chain in same delta cycle
        #5;
        clk = 1;
        #0;  // Let events propagate
        #0;  // Additional delta for event chain
        #0;
        test_count++;
        // Order should be: 1, then 2, then 3 => 123
        if (order_tracker == 123) pass_count++;
        else $display("FAIL: Event chain order = %0d (expected 123)", order_tracker);

        #5;
        clk = 0;
        order_tracker = 0;

        // Test 2: Second trigger
        #5;
        clk = 1;
        #0;
        #0;
        #0;
        test_count++;
        if (order_tracker == 123) pass_count++;
        else $display("FAIL: Second event chain = %0d (expected 123)", order_tracker);

        $display("Chapter 4.3-4.4 Event Ordering: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
