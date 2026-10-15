/*
:name: test_net_types_edge_cases
:description: Net types edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.3 6.6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_types_edge_cases.expected
*/
// IEEE 1800-2023 §6.6: Net types edge cases
// Tests for wire, wand, wor, tri, tri0, tri1

module test_net_types_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    // Basic wire
    wire w1;
    wire [7:0] w8;

    // Wired AND
    wand wa;
    wand [3:0] wa4;

    // Wired OR
    wor wo;
    wor [3:0] wo4;

    // Tri-state
    tri t1;
    tri [7:0] t8;

    // Tri with pull-down
    tri0 t0;

    // Tri with pull-up
    tri1 t1_pu;

    // Drivers
    logic drv1, drv2;
    logic [7:0] drv8_a, drv8_b;
    logic [3:0] drv4_a, drv4_b;

    // Wire assignments
    assign w1 = drv1;
    assign w8 = drv8_a;

    // Wand with multiple drivers
    assign wa = drv1;
    assign wa = drv2;
    assign wa4 = drv4_a;
    assign wa4 = drv4_b;

    // Wor with multiple drivers
    assign wo = drv1;
    assign wo = drv2;
    assign wo4 = drv4_a;
    assign wo4 = drv4_b;

    // Tri with multiple drivers
    assign t1 = drv1 ? 1'b1 : 1'bz;
    assign t8 = drv8_a;

    // Tri0/tri1
    assign t0 = drv1 ? 1'b1 : 1'bz;
    assign t1_pu = drv1 ? 1'b0 : 1'bz;

    initial begin
        // Test 1: Basic wire
        test_count++;
        drv1 = 1;
        #1;
        if (w1 == 1) begin
            pass_count++;
            $display("Test 1 PASS: wire = %b", w1);
        end else begin
            $display("Test 1 FAIL: wire = %b", w1);
        end

        // Test 2: Wire vector
        test_count++;
        drv8_a = 8'hAB;
        #1;
        if (w8 == 8'hAB) begin
            pass_count++;
            $display("Test 2 PASS: wire[7:0] = %h", w8);
        end else begin
            $display("Test 2 FAIL: wire = %h", w8);
        end

        // Test 3: Wand both 1
        test_count++;
        drv1 = 1;
        drv2 = 1;
        #1;
        if (wa == 1) begin
            pass_count++;
            $display("Test 3 PASS: wand(1,1) = %b", wa);
        end else begin
            $display("Test 3 FAIL: wand = %b", wa);
        end

        // Test 4: Wand one 0
        test_count++;
        drv1 = 1;
        drv2 = 0;
        #1;
        if (wa == 0) begin
            pass_count++;
            $display("Test 4 PASS: wand(1,0) = %b", wa);
        end else begin
            $display("Test 4 FAIL: wand = %b", wa);
        end

        // Test 5: Wor both 0
        test_count++;
        drv1 = 0;
        drv2 = 0;
        #1;
        if (wo == 0) begin
            pass_count++;
            $display("Test 5 PASS: wor(0,0) = %b", wo);
        end else begin
            $display("Test 5 FAIL: wor = %b", wo);
        end

        // Test 6: Wor one 1
        test_count++;
        drv1 = 0;
        drv2 = 1;
        #1;
        if (wo == 1) begin
            pass_count++;
            $display("Test 6 PASS: wor(0,1) = %b", wo);
        end else begin
            $display("Test 6 FAIL: wor = %b", wo);
        end

        // Test 7: Wand vector
        test_count++;
        drv4_a = 4'b1111;
        drv4_b = 4'b1010;
        #1;
        if (wa4 == 4'b1010) begin
            pass_count++;
            $display("Test 7 PASS: wand[3:0] = %b", wa4);
        end else begin
            $display("Test 7 FAIL: wand = %b", wa4);
        end

        // Test 8: Wor vector
        test_count++;
        drv4_a = 4'b0000;
        drv4_b = 4'b1010;
        #1;
        if (wo4 == 4'b1010) begin
            pass_count++;
            $display("Test 8 PASS: wor[3:0] = %b", wo4);
        end else begin
            $display("Test 8 FAIL: wor = %b", wo4);
        end

        // Test 9: Tri driven
        test_count++;
        drv1 = 1;
        #1;
        if (t1 === 1'b1) begin
            pass_count++;
            $display("Test 9 PASS: tri driven = %b", t1);
        end else begin
            $display("Test 9 FAIL: tri driven = %b", t1);
        end

        // Test 10: Tri vector
        test_count++;
        drv8_a = 8'h55;
        #1;
        if (t8 == 8'h55) begin
            pass_count++;
            $display("Test 10 PASS: tri[7:0] = %h", t8);
        end else begin
            $display("Test 10 FAIL: tri = %h", t8);
        end

        // Test 11: Tri0 pulled down
        test_count++;
        drv1 = 0;  // Z drive
        #1;
        if (t0 === 1'b0) begin
            pass_count++;
            $display("Test 11 PASS: tri0 = %b (pull-down)", t0);
        end else begin
            $display("Test 11 FAIL: tri0 undriven = %b", t0);
        end

        // Test 12: Tri0 driven high
        test_count++;
        drv1 = 1;
        #1;
        if (t0 == 1) begin
            pass_count++;
            $display("Test 12 PASS: tri0 driven high = %b", t0);
        end else begin
            $display("Test 12 FAIL: tri0 unexpected = %b", t0);
        end

        // Test 13: Tri1 pulled up
        test_count++;
        drv1 = 0;  // Z drive
        #1;
        if (t1_pu === 1'b1) begin
            pass_count++;
            $display("Test 13 PASS: tri1 = %b (pull-up)", t1_pu);
        end else begin
            $display("Test 13 FAIL: tri1 undriven = %b", t1_pu);
        end

        // Test 14: Tri1 driven low
        test_count++;
        drv1 = 1;  // Drive low through conditional
        #1;
        if (t1_pu === 1'b0) begin
            pass_count++;
            $display("Test 14 PASS: tri1 driven = %b", t1_pu);
        end else begin
            $display("Test 14 FAIL: tri1 driven = %b", t1_pu);
        end

        // Test 15: Wire toggle
        test_count++;
        drv1 = 0;
        #1;
        drv1 = 1;
        #1;
        if (w1 == 1) begin
            pass_count++;
            $display("Test 15 PASS: Wire toggle");
        end else begin
            $display("Test 15 FAIL");
        end

        // Test 16: Wand all ones
        test_count++;
        drv4_a = 4'b1111;
        drv4_b = 4'b1111;
        #1;
        if (wa4 == 4'b1111) begin
            pass_count++;
            $display("Test 16 PASS: wand all ones = %b", wa4);
        end else begin
            $display("Test 16 FAIL: wand = %b", wa4);
        end

        // Test 17: Wor all zeros
        test_count++;
        drv4_a = 4'b0000;
        drv4_b = 4'b0000;
        #1;
        if (wo4 == 4'b0000) begin
            pass_count++;
            $display("Test 17 PASS: wor all zeros = %b", wo4);
        end else begin
            $display("Test 17 FAIL: wor = %b", wo4);
        end

        // Test 18: Wire pattern
        test_count++;
        drv8_a = 8'hAA;
        #1;
        if (w8 == 8'hAA) begin
            pass_count++;
            $display("Test 18 PASS: Wire pattern = %h", w8);
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: Mixed wand
        test_count++;
        drv4_a = 4'b1100;
        drv4_b = 4'b1010;
        #1;
        if (wa4 == 4'b1000) begin
            pass_count++;
            $display("Test 19 PASS: wand mixed = %b", wa4);
        end else begin
            $display("Test 19 FAIL: wand = %b", wa4);
        end

        // Test 20: Mixed wor
        test_count++;
        drv4_a = 4'b1100;
        drv4_b = 4'b0011;
        #1;
        if (wo4 == 4'b1111) begin
            pass_count++;
            $display("Test 20 PASS: wor mixed = %b", wo4);
        end else begin
            $display("Test 20 FAIL: wor = %b", wo4);
        end

        $display("=== Net Types Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
