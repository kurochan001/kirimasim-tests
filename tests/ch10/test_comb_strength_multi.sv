/*
:name: test_comb_strength_multi
:description: Test: Strength resolution with multiple drivers
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.4 28.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comb_strength_multi.expected
*/
// Test: Strength resolution with multiple drivers
// Verifies IEEE 1800-2023 §10.3.3 strength resolution
module test_comb_strength_multi;
    int pass_count = 0;

    // T1: Strong vs weak driver
    wire w1;
    assign (strong0, strong1) w1 = 1'b1;
    assign (weak0, weak1) w1 = 1'b0;

    // T2: Pull-up and pull-down
    wire w2;
    pullup(w2);

    // T3: Two equal strength drivers (should resolve to X)
    wire w3;
    assign (strong0, strong1) w3 = 1'b1;
    assign (strong0, strong1) w3 = 1'b0;

    // T4: Supply strength overrides all
    wire w4;
    assign (supply0, supply1) w4 = 1'b1;
    assign (strong0, strong1) w4 = 1'b0;

    // T5: Highz0 driver has no effect when driving 0
    wire w5;
    assign (strong0, strong1) w5 = 1'b1;
    assign (highz0, weak1) w5 = 1'b0;

    // T6: Pull vs weak
    wire w6;
    assign (pull0, pull1) w6 = 1'b1;
    assign (weak0, weak1) w6 = 1'b0;

    initial begin
        #1;

        // T1: Strong beats weak
        if (w1 === 1'b1) begin
            $display("T1: PASS - strong(1) beats weak(0): w1=%b", w1);
            pass_count++;
        end else
            $display("T1: FAIL - w1=%b (expected 1)", w1);

        // T2: Pullup makes wire 1
        if (w2 === 1'b1) begin
            $display("T2: PASS - pullup: w2=%b", w2);
            pass_count++;
        end else
            $display("T2: FAIL - w2=%b (expected 1)", w2);

        // T3: Equal strength conflict -> X
        if (w3 === 1'bx) begin
            $display("T3: PASS - equal strength conflict: w3=%b (X)", w3);
            pass_count++;
        end else
            $display("T3: FAIL - w3=%b (expected x)", w3);

        // T4: Supply beats strong
        if (w4 === 1'b1) begin
            $display("T4: PASS - supply(1) beats strong(0): w4=%b", w4);
            pass_count++;
        end else
            $display("T4: FAIL - w4=%b (expected 1)", w4);

        // T5: Highz has no effect
        if (w5 === 1'b1) begin
            $display("T5: PASS - strong(1) + highz: w5=%b", w5);
            pass_count++;
        end else
            $display("T5: FAIL - w5=%b (expected 1)", w5);

        // T6: Pull beats weak
        if (w6 === 1'b1) begin
            $display("T6: PASS - pull(1) beats weak(0): w6=%b", w6);
            pass_count++;
        end else
            $display("T6: FAIL - w6=%b (expected 1)", w6);

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_strength_multi");
        else
            $display("FAIL: test_comb_strength_multi (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
