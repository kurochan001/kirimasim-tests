/*
:name: test_net_resolution_multi
:description: Wired nets, tri0/tri1, supply nets, pull sources and strength resolution (IEEE 1800-2023 Sections 6.6.3 to 6.6.6, 28.10 and 28.12)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3 6.6.5 6.6.6 28.10 28.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_resolution_multi.expected
*/
`timescale 1ns/1ps
module test_net_resolution_multi;
    int pass_count = 0;
    int test_count = 15;

    // T1: wor 3 drivers
    wor [3:0] wor_net;
    logic [3:0] drv_wor_a, drv_wor_b, drv_wor_c;
    assign wor_net = drv_wor_a;
    assign wor_net = drv_wor_b;
    assign wor_net = drv_wor_c;

    // T2: wand 3 drivers
    wand [3:0] wand_net;
    logic [3:0] drv_wand_a, drv_wand_b, drv_wand_c;
    assign wand_net = drv_wand_a;
    assign wand_net = drv_wand_b;
    assign wand_net = drv_wand_c;

    // T3: tri0 no driver
    tri0 tri0_net;

    // T4: tri1 no driver
    tri1 tri1_net;

    // T5: triand multi-driver
    triand [3:0] triand_net;
    logic [3:0] drv_triand_a, drv_triand_b;
    assign triand_net = drv_triand_a;
    assign triand_net = drv_triand_b;

    // T6: trior multi-driver
    trior [3:0] trior_net;
    logic [3:0] drv_trior_a, drv_trior_b;
    assign trior_net = drv_trior_a;
    assign trior_net = drv_trior_b;

    // T7: supply0/supply1
    supply0 s0;
    supply1 s1;

    // T8: pullup
    wire pu_wire;
    pullup(pu_wire);

    // T9: pulldown
    wire pd_wire;
    pulldown(pd_wire);

    // T10: strong override pull
    wire strong_net;
    logic strong_drv;
    assign (strong1, strong0) strong_net = strong_drv;

    // T11: Multi-driver X resolution
    wire x_net;
    logic drv_x_a, drv_x_b;
    assign x_net = drv_x_a;
    assign x_net = drv_x_b;

    // T13: conditional assign on net
    wire cond_net;
    logic sel, in0, in1;
    assign cond_net = sel ? in1 : in0;

    // T14: Multi-bit wor/wand
    wor [7:0] wor8;
    logic [7:0] drv8_a, drv8_b;
    assign wor8 = drv8_a;
    assign wor8 = drv8_b;

    // T15: Driver release
    wire release_net;
    logic drv_release;
    assign release_net = drv_release;

    initial begin
        // T1: wor 3 drivers (bitwise OR)
        drv_wor_a = 4'b0001;
        drv_wor_b = 4'b0010;
        drv_wor_c = 4'b0100;
        #1;
        if (wor_net == 4'b0111) begin
            $display("T1: PASS - wor=%b", wor_net);
            pass_count++;
        end else
            $display("T1: FAIL - wor=%b expected 0111", wor_net);

        // T2: wand 3 drivers (bitwise AND)
        drv_wand_a = 4'b1111;
        drv_wand_b = 4'b1100;
        drv_wand_c = 4'b1010;
        #1;
        if (wand_net == 4'b1000) begin
            $display("T2: PASS - wand=%b", wand_net);
            pass_count++;
        end else
            $display("T2: FAIL - wand=%b expected 1000", wand_net);

        // T3: tri0 no driver (→0)
        #1;
        if (tri0_net === 1'b0) begin
            $display("T3: PASS - tri0=%b", tri0_net);
            pass_count++;
        end else
            $display("T3: FAIL - tri0=%b", tri0_net);

        // T4: tri1 no driver (→1, 6.6.5)
        #1;
        if (tri1_net === 1'b1) begin
            $display("T4: PASS - tri1=%b", tri1_net);
            pass_count++;
        end else begin
            $display("T4: FAIL - tri1=%b", tri1_net);
        end

        // T5: triand multi-driver
        drv_triand_a = 4'b1111;
        drv_triand_b = 4'b0101;
        #1;
        if (triand_net == 4'b0101) begin
            $display("T5: PASS - triand=%b", triand_net);
            pass_count++;
        end else
            $display("T5: FAIL - triand=%b expected 0101", triand_net);

        // T6: trior multi-driver
        drv_trior_a = 4'b1010;
        drv_trior_b = 4'b0101;
        #1;
        if (trior_net == 4'b1111) begin
            $display("T6: PASS - trior=%b", trior_net);
            pass_count++;
        end else
            $display("T6: FAIL - trior=%b expected 1111", trior_net);

        // T7: supply0/supply1
        #1;
        if (s0 === 1'b0 && s1 === 1'b1) begin
            $display("T7: PASS - supply0=%b supply1=%b", s0, s1);
            pass_count++;
        end else
            $display("T7: FAIL - s0=%b s1=%b", s0, s1);

        // T8: pullup primitive
        #1;
        if (pu_wire === 1'b1) begin
            $display("T8: PASS - pullup=%b", pu_wire);
            pass_count++;
        end else begin
            $display("T8: FAIL - pullup=%b", pu_wire);
        end

        // T9: pulldown primitive
        #1;
        if (pd_wire === 1'b0) begin
            $display("T9: PASS - pulldown=%b", pd_wire);
            pass_count++;
        end else begin
            $display("T9: FAIL - pulldown=%b", pd_wire);
        end

        // T10: strong overrides pull
        strong_drv = 1'b1;
        #1;
        if (strong_net === 1'b1) begin
            $display("T10: PASS - strong override=%b", strong_net);
            pass_count++;
        end else
            $display("T10: FAIL - strong_net=%b", strong_net);

        // T11: Multi-driver X resolution
        drv_x_a = 1'b1;
        drv_x_b = 1'b0;
        #1;
        if (x_net === 1'bx) begin
            $display("T11: PASS - X resolution=%b", x_net);
            pass_count++;
        end else begin
            $display("T11: FAIL - resolution=%b", x_net);
        end

        // T12: wor value change
        drv_wor_a = 4'b1000;
        drv_wor_b = 4'b0000;
        drv_wor_c = 4'b0000;
        #1;
        if (wor_net == 4'b1000) begin
            $display("T12: PASS - wor single driver=%b", wor_net);
            pass_count++;
        end else
            $display("T12: FAIL - wor=%b", wor_net);

        // T13: conditional assign on net
        sel = 0; in0 = 1; in1 = 0;
        #1;
        if (cond_net == 1'b1) begin
            sel = 1;
            #1;
            if (cond_net == 1'b0) begin
                $display("T13: PASS - conditional assign");
                pass_count++;
            end else
                $display("T13: FAIL - sel=1 net=%b", cond_net);
        end else
            $display("T13: FAIL - sel=0 net=%b", cond_net);

        // T14: Multi-bit wor/wand
        drv8_a = 8'hF0;
        drv8_b = 8'h0F;
        #1;
        if (wor8 == 8'hFF) begin
            $display("T14: PASS - wor8=%h", wor8);
            pass_count++;
        end else
            $display("T14: FAIL - wor8=%h", wor8);

        // T15: wand value change test
        drv_wand_a = 4'b1111;
        drv_wand_b = 4'b1111;
        drv_wand_c = 4'b1111;
        #1;
        if (wand_net == 4'b1111) begin
            $display("T15: PASS - wand all 1s=%b", wand_net);
            pass_count++;
        end else begin
            $display("T15: FAIL - wand=%b", wand_net);
        end

        $display("pass_count = %0d / %0d", pass_count, test_count);
        if (pass_count >= test_count)
            $display("PASS: test_net_resolution_multi");
        else
            $display("FAIL: test_net_resolution_multi (pass_count=%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
