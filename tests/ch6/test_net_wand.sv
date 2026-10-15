/*
:name: test_net_wand
:description: Wand net type (wired-AND)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_wand.expected
*/
// Wand net type (wired-AND)
module test_net_wand;
    // Scenario 1: Single driver wand
    wand w1;
    assign w1 = 1'b1;

    // Scenario 2: Multiple drivers - both 1
    wand w2;
    assign w2 = 1'b1;
    assign w2 = 1'b1;

    // Scenario 3: Multiple drivers - one 0
    wand w3;
    assign w3 = 1'b1;
    assign w3 = 1'b0;

    // Scenario 4: Multi-bit wand
    wand [3:0] w4;
    assign w4 = 4'b1111;
    assign w4 = 4'b1010;

    // Scenario 5: Wand with conditional drivers
    reg sel;
    wand w5;
    assign w5 = sel ? 1'b1 : 1'b0;
    assign w5 = 1'b1;

    initial begin
        sel = 0;
        #1;

        // Test Scenario 1: Single driver
        if (w1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Single driver wand expected 1, got %b", w1);
            $finish;
        end

        // Test Scenario 2: Both drivers 1, result should be 1
        if (w2 !== 1'b1) begin
            $display("FAIL: Scenario 2 - Wand (1 & 1) expected 1, got %b", w2);
            $finish;
        end

        // Test Scenario 3: One driver 0, result should be 0 (wired-AND)
        if (w3 !== 1'b0) begin
            $display("FAIL: Scenario 3 - Wand (1 & 0) expected 0, got %b", w3);
            $finish;
        end

        // Test Scenario 4: Multi-bit wand (1111 & 1010 = 1010)
        if (w4 !== 4'b1010) begin
            $display("FAIL: Scenario 4 - Multi-bit wand expected 1010, got %b", w4);
            $finish;
        end

        // Test Scenario 5: Conditional (0 & 1 = 0)
        if (w5 !== 1'b0) begin
            $display("FAIL: Scenario 5 - Wand conditional expected 0, got %b", w5);
            $finish;
        end

        sel = 1;
        #1;
        // After sel=1: (1 & 1 = 1)
        if (w5 !== 1'b1) begin
            $display("FAIL: Scenario 5 - Wand conditional expected 1 after sel=1, got %b", w5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
