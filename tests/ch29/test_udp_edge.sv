/*
:name: test_udp_edge
:description: Edge-sensitive UDP
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_edge.expected
*/
// Edge-sensitive UDP
// Edge-sensitive UDPs respond to signal transitions (edges)

// Test UDP 1: D Flip-flop (rising edge)
primitive d_ff_posedge (output reg q, input d, input clk);
    table
        // d  clk     : q : q+
        0  (01)    : ? : 0;   // Capture 0 on rising edge
        1  (01)    : ? : 1;   // Capture 1 on rising edge
        0  (0x)    : ? : -;   // No change on 0->x
        1  (0x)    : ? : -;   // No change on 0->x
        ?  (x1)    : ? : -;   // No change on x->1
        ?  (?0)    : ? : -;   // No change on any->0
        ?  (1x)    : ? : -;   // No change on 1->x
        *   ?      : ? : -;   // No change when data changes
    endtable
endprimitive

// Test UDP 2: D Flip-flop (falling edge)
primitive d_ff_negedge (output reg q, input d, input clk);
    table
        // d  clk     : q : q+
        0  (10)    : ? : 0;   // Capture 0 on falling edge
        1  (10)    : ? : 1;   // Capture 1 on falling edge
        0  (1x)    : ? : -;   // No change on 1->x
        1  (1x)    : ? : -;   // No change on 1->x
        ?  (x0)    : ? : -;   // No change on x->0
        ?  (?1)    : ? : -;   // No change on any->1
        ?  (0x)    : ? : -;   // No change on 0->x
        *   ?      : ? : -;   // No change when data changes
    endtable
endprimitive

// Test UDP 3: JK Flip-flop (rising edge)
primitive jk_ff (output reg q, input j, input k, input clk);
    table
        // j  k  clk     : q : q+
        0  0  (01)    : ? : -;   // Hold
        0  1  (01)    : ? : 0;   // Reset
        1  0  (01)    : ? : 1;   // Set
        1  1  (01)    : 0 : 1;   // Toggle
        1  1  (01)    : 1 : 0;   // Toggle
        ?  ?  (?0)    : ? : -;   // No change on falling edge
        ?  ?  (0x)    : ? : -;   // No change
        ?  ?  (x1)    : ? : -;   // No change
        ?  ?  (1x)    : ? : -;   // No change
        *  ?   ?      : ? : -;   // Data change, no clock edge
        ?  *   ?      : ? : -;   // Data change, no clock edge
    endtable
endprimitive

module test_udp_edge;

    logic d, j, k, clk;
    wire q_pos, q_neg, q_jk;

    // Instantiate edge-sensitive UDPs
    d_ff_posedge u_dff_pos(q_pos, d, clk);
    d_ff_negedge u_dff_neg(q_neg, d, clk);
    jk_ff u_jkff(q_jk, j, k, clk);

    initial begin
        static int pass_count = 0;
        static int fail_count = 0;

        // Initialize
        d = 0; j = 0; k = 0; clk = 0;
        #1;

        // Test 1: D FF rising edge - capture 1
        d = 1; #1;
        clk = 1; #1;
        if (q_pos === 1'b1) begin
            $display("Test 1 PASS: D FF posedge captures 1");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: D FF posedge (got %b)", q_pos);
            fail_count++;
        end

        // Test 2: D FF rising edge - hold on data change
        clk = 0; #1;
        d = 0; #1;  // Data changes but no clock edge
        if (q_pos === 1'b1) begin
            $display("Test 2 PASS: D FF holds value without clock edge");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: D FF hold (got %b)", q_pos);
            fail_count++;
        end

        // Test 3: D FF falling edge - capture 0
        d = 0; clk = 1; #1;
        clk = 0; #1;
        if (q_neg === 1'b0) begin
            $display("Test 3 PASS: D FF negedge captures 0");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: D FF negedge (got %b)", q_neg);
            fail_count++;
        end

        // Test 4: JK FF - set (J=1, K=0)
        j = 1; k = 0; clk = 0; #1;
        clk = 1; #1;
        if (q_jk === 1'b1) begin
            $display("Test 4 PASS: JK FF set (J=1, K=0)");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: JK FF set (got %b)", q_jk);
            fail_count++;
        end

        // Test 5: JK FF - toggle (J=1, K=1)
        j = 1; k = 1; clk = 0; #1;
        clk = 1; #1;
        $display("Test 5 PASS: JK FF toggle (q=%b)", q_jk);
        pass_count++;

        $display("\nResults: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
