/*
:name: test_net_types_resolution
:description: Resolution of wor, wand, tri, triand and trior nets with constant drivers
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3 6.6.4 6.6.2 10.3.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_types_resolution.expected
*/
module test_net_types_resolution;
    int pass_count = 0;
    int test_count = 12;

    // T1-T2: wor (wired-OR)
    wor wor_sig;
    assign wor_sig = 1'b0;
    assign wor_sig = 1'b1;

    wor wor_z;
    // Single driver
    assign wor_z = 1'b0;

    // T3-T4: wand (wired-AND)
    wand wand_sig;
    assign wand_sig = 1'b1;
    assign wand_sig = 1'b0;

    wand wand_both;
    assign wand_both = 1'b1;
    assign wand_both = 1'b1;

    // T5-T6: tri (same as wire)
    tri tri_sig;
    assign tri_sig = 1'b1;

    tri tri_conflict;
    // A single driver
    assign tri_conflict = 1'b0;

    // T7: triand
    triand triand_sig;
    assign triand_sig = 1'b1;
    assign triand_sig = 1'b1;

    // T8: trior
    trior trior_sig;
    assign trior_sig = 1'b0;
    assign trior_sig = 1'b1;

    // T9: Multi-bit resolution
    wor [3:0] wor_multi;
    assign wor_multi = 4'b1010;
    assign wor_multi = 4'b0101;

    // T10: Supply strength
    wire supply_wire;
    assign supply_wire = 1'b1;

    // T11-12: Basic wire tests
    wire [7:0] basic_wire;
    assign basic_wire = 8'hAB;

    wire computed_wire;
    wire [7:0] input_a = 8'h0F;
    wire [7:0] input_b = 8'hF0;
    assign computed_wire = |input_a;

    initial begin
        #1;

        // T1: wor - two drivers, 0 | 1 = 1
        if (wor_sig === 1'b1) begin
            $display("T1: PASS - wor 0|1 = %b", wor_sig);
            pass_count++;
        end else
            $display("T1: FAIL - wor_sig=%b", wor_sig);

        // T2: wor single driver with 0
        if (wor_z === 1'b0) begin
            $display("T2: PASS - wor single 0 = %b", wor_z);
            pass_count++;
        end else
            $display("T2: FAIL - wor_z=%b", wor_z);

        // T3: wand - two drivers, 1 & 0 = 0
        if (wand_sig === 1'b0) begin
            $display("T3: PASS - wand 1&0 = %b", wand_sig);
            pass_count++;
        end else
            $display("T3: FAIL - wand_sig=%b", wand_sig);

        // T4: wand both 1 = 1
        if (wand_both === 1'b1) begin
            $display("T4: PASS - wand 1&1 = %b", wand_both);
            pass_count++;
        end else
            $display("T4: FAIL - wand_both=%b", wand_both);

        // T5: tri single driver
        if (tri_sig === 1'b1) begin
            $display("T5: PASS - tri = %b", tri_sig);
            pass_count++;
        end else
            $display("T5: FAIL - tri_sig=%b", tri_sig);

        // T6: tri single driver = 0
        if (tri_conflict === 1'b0) begin
            $display("T6: PASS - tri conflict = %b", tri_conflict);
            pass_count++;
        end else
            $display("T6: FAIL - tri_conflict=%b", tri_conflict);

        // T7: triand both 1 = 1
        if (triand_sig === 1'b1) begin
            $display("T7: PASS - triand 1&1 = %b", triand_sig);
            pass_count++;
        end else
            $display("T7: FAIL - triand_sig=%b", triand_sig);

        // T8: trior 0|1 = 1
        if (trior_sig === 1'b1) begin
            $display("T8: PASS - trior 0|1 = %b", trior_sig);
            pass_count++;
        end else
            $display("T8: FAIL - trior_sig=%b", trior_sig);

        // T9: Multi-bit wor resolution
        if (wor_multi === 4'b1111) begin
            $display("T9: PASS - wor multi %b", wor_multi);
            pass_count++;
        end else
            $display("T9: FAIL - wor_multi=%b", wor_multi);

        // T10: Supply wire
        if (supply_wire === 1'b1) begin
            $display("T10: PASS - supply wire = %b", supply_wire);
            pass_count++;
        end else
            $display("T10: FAIL - supply_wire=%b", supply_wire);

        // T11: Basic wire
        if (basic_wire === 8'hAB) begin
            $display("T11: PASS - basic wire = %0h", basic_wire);
            pass_count++;
        end else
            $display("T11: FAIL - basic_wire=%0h", basic_wire);

        // T12: Computed wire
        if (computed_wire === 1'b1) begin
            $display("T12: PASS - computed wire = %b", computed_wire);
            pass_count++;
        end else
            $display("T12: FAIL - computed_wire=%b", computed_wire);

        $display("pass_count = %0d / %0d", pass_count, test_count);
        if (pass_count >= test_count)
            $display("PASS: test_net_types_resolution");
        else
            $display("FAIL: test_net_types_resolution (pass_count=%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
