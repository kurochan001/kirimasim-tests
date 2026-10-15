/*
:name: test_net_trior
:description: Trior net type (tri-state OR)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_trior.expected
*/
// Trior net type (tri-state OR)
module test_net_trior;
    // Scenario 1: Single driver trior
    trior t1;
    assign t1 = 1'b0;

    // Scenario 2: Multiple drivers - both 0
    trior t2;
    assign t2 = 1'b0;
    assign t2 = 1'b0;

    // Scenario 3: Multiple drivers - one 1
    trior t3;
    assign t3 = 1'b0;
    assign t3 = 1'b1;

    // Scenario 4: Trior with Z driver
    trior t4;
    reg en4;
    assign t4 = 1'b0;
    assign t4 = en4 ? 1'b1 : 1'bz;

    // Scenario 5: Multi-bit trior
    trior [3:0] t5;
    assign t5 = 4'b0000;
    assign t5 = 4'b0011;

    initial begin
        en4 = 0;
        #1;

        // Test Scenario 1: Single driver
        if (t1 !== 1'b0) begin
            $display("FAIL: Scenario 1 - Single driver trior expected 0, got %b", t1);
            $finish;
        end

        // Test Scenario 2: Both drivers 0
        if (t2 !== 1'b0) begin
            $display("FAIL: Scenario 2 - Trior (0 | 0) expected 0, got %b", t2);
            $finish;
        end

        // Test Scenario 3: One driver 1 (wired-OR)
        if (t3 !== 1'b1) begin
            $display("FAIL: Scenario 3 - Trior (0 | 1) expected 1, got %b", t3);
            $finish;
        end

        // Test Scenario 4: One driver Z (0 | Z = 0)
        if (t4 !== 1'b0) begin
            $display("FAIL: Scenario 4 - Trior (0 | z) expected 0, got %b", t4);
            $finish;
        end
        en4 = 1;
        #1;
        // (0 | 1 = 1)
        if (t4 !== 1'b1) begin
            $display("FAIL: Scenario 4 - Trior (0 | 1) expected 1, got %b", t4);
            $finish;
        end

        // Test Scenario 5: Multi-bit trior (0000 | 0011 = 0011)
        if (t5 !== 4'b0011) begin
            $display("FAIL: Scenario 5 - Multi-bit trior expected 0011, got %b", t5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
