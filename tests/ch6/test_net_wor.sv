/*
:name: test_net_wor
:description: Wor net type (wired-OR)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_wor.expected
*/
// Wor net type (wired-OR)
module test_net_wor;
    // Scenario 1: Single driver wor
    wor w1;
    assign w1 = 1'b0;

    // Scenario 2: Multiple drivers - both 0
    wor w2;
    assign w2 = 1'b0;
    assign w2 = 1'b0;

    // Scenario 3: Multiple drivers - one 1
    wor w3;
    assign w3 = 1'b0;
    assign w3 = 1'b1;

    // Scenario 4: Multi-bit wor
    wor [3:0] w4;
    assign w4 = 4'b0000;
    assign w4 = 4'b1010;

    // Scenario 5: Wor with conditional drivers
    reg sel;
    wor w5;
    assign w5 = sel ? 1'b1 : 1'b0;
    assign w5 = 1'b0;

    initial begin
        sel = 0;
        #1;

        // Test Scenario 1: Single driver
        if (w1 !== 1'b0) begin
            $display("FAIL: Scenario 1 - Single driver wor expected 0, got %b", w1);
            $finish;
        end

        // Test Scenario 2: Both drivers 0, result should be 0
        if (w2 !== 1'b0) begin
            $display("FAIL: Scenario 2 - Wor (0 | 0) expected 0, got %b", w2);
            $finish;
        end

        // Test Scenario 3: One driver 1, result should be 1 (wired-OR)
        if (w3 !== 1'b1) begin
            $display("FAIL: Scenario 3 - Wor (0 | 1) expected 1, got %b", w3);
            $finish;
        end

        // Test Scenario 4: Multi-bit wor (0000 | 1010 = 1010)
        if (w4 !== 4'b1010) begin
            $display("FAIL: Scenario 4 - Multi-bit wor expected 1010, got %b", w4);
            $finish;
        end

        // Test Scenario 5: Conditional (0 | 0 = 0)
        if (w5 !== 1'b0) begin
            $display("FAIL: Scenario 5 - Wor conditional expected 0, got %b", w5);
            $finish;
        end

        sel = 1;
        #1;
        // After sel=1: (1 | 0 = 1)
        if (w5 !== 1'b1) begin
            $display("FAIL: Scenario 5 - Wor conditional expected 1 after sel=1, got %b", w5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
