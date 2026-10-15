/*
:name: test_udp_seq
:description: Level-sensitive and edge-sensitive sequential UDPs
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.3 29.5 29.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_seq.expected
*/
// Level-sensitive and edge-sensitive sequential UDPs

// Test UDP 1: D Latch (level-sensitive)
primitive d_latch (output reg q, input d, input en);
    table
        // d  en : q : q+
        0   1 : ? : 0;   // Latch 0 when enabled
        1   1 : ? : 1;   // Latch 1 when enabled
        ?   0 : ? : -;   // Hold when disabled
    endtable
endprimitive

// Test UDP 2: SR Latch
primitive sr_latch (output reg q, input s, input r);
    table
        // s  r  : q : q+
        0   0  : ? : -;   // Hold
        0   1  : ? : 0;   // Reset
        1   0  : ? : 1;   // Set
        1   1  : ? : x;   // Invalid (both set and reset)
    endtable
endprimitive

// Test UDP 3: T Flip-flop (toggle)
primitive t_ff (q, t, clk);
    output q;
    reg q;
    input t, clk;
    initial q = 0;  // 29.3.3
    table
        // t  clk     : q : q+
        0  (01)    : ? : -;   // No toggle on rising edge when t=0
        1  (01)    : 0 : 1;   // Toggle 0->1 on rising edge when t=1
        1  (01)    : 1 : 0;   // Toggle 1->0 on rising edge when t=1
        ?  (0x)    : ? : -;   // No change on 0->x
        ?  (x1)    : ? : -;   // No change on x->1
        ?  (?0)    : ? : -;   // No change on falling edge
        ?  (1x)    : ? : -;   // No change on 1->x
        (??) ?     : ? : -;   // A change of t alone keeps q; an unlisted
                              // transition would make q x (29.6)
    endtable
endprimitive

module test_udp_seq;

    logic d, en, s, r, t, clk;
    wire q_dlatch, q_srlatch, q_tff;

    // Instantiate sequential UDPs
    d_latch u_dlatch(q_dlatch, d, en);
    sr_latch u_srlatch(q_srlatch, s, r);
    t_ff u_tff(q_tff, t, clk);

    initial begin
        static int pass_count = 0;
        static int fail_count = 0;

        // Initialize
        d = 0; en = 0; s = 0; r = 0; t = 0; clk = 0;
        #1;

        // Test 1: D Latch - latch data when enabled
        d = 1; en = 1; #1;
        if (q_dlatch === 1'b1) begin
            $display("Test 1 PASS: D Latch latches 1 when enabled");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: D Latch output (got %b)", q_dlatch);
            fail_count++;
        end

        // Test 2: D Latch - hold when disabled
        // Close the latch before changing d: changes of two inputs in the
        // same time step reach the UDP in no defined order (4.7).
        en = 0; #1;
        d = 0; #1;
        if (q_dlatch === 1'b1) begin
            $display("Test 2 PASS: D Latch holds value when disabled");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: D Latch hold (got %b)", q_dlatch);
            fail_count++;
        end

        // Test 3: SR Latch - set
        s = 1; r = 0; #1;
        if (q_srlatch === 1'b1) begin
            $display("Test 3 PASS: SR Latch set");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: SR Latch set (got %b)", q_srlatch);
            fail_count++;
        end

        // Test 4: SR Latch - reset
        s = 0; r = 1; #1;
        if (q_srlatch === 1'b0) begin
            $display("Test 4 PASS: SR Latch reset");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: SR Latch reset (got %b)", q_srlatch);
            fail_count++;
        end

        // Test 5: T Flip-flop - toggle on rising edge
        t = 1; clk = 0; #1;
        clk = 1; #1;
        if (q_tff === 1'b1) begin
            pass_count++;
            $display("Test 5 PASS: T Flip-flop toggle (q=%b)", q_tff);
        end else begin
            $display("Test 5 FAIL: T Flip-flop toggle (q=%b)", q_tff);
            fail_count++;
        end

        $display("\nResults: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
