/*
:name: test_net_triand
:description: Triand net type (tri-state AND)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_triand.expected
*/
// Triand net type (tri-state AND)
module test_net_triand;
    // Scenario 1: Single driver triand
    triand t1;
    assign t1 = 1'b1;

    // Scenario 2: Multiple drivers - both 1
    triand t2;
    assign t2 = 1'b1;
    assign t2 = 1'b1;

    // Scenario 3: Multiple drivers - one 0
    triand t3;
    assign t3 = 1'b1;
    assign t3 = 1'b0;

    // Scenario 4: Triand with Z driver
    triand t4;
    reg en4;
    assign t4 = 1'b1;
    assign t4 = en4 ? 1'b0 : 1'bz;

    // Scenario 5: Multi-bit triand
    triand [3:0] t5;
    assign t5 = 4'b1111;
    assign t5 = 4'b1100;

    initial begin
        en4 = 0;
        #1;

        // Test Scenario 1: Single driver
        if (t1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Single driver triand expected 1, got %b", t1);
            $finish;
        end

        // Test Scenario 2: Both drivers 1
        if (t2 !== 1'b1) begin
            $display("FAIL: Scenario 2 - Triand (1 & 1) expected 1, got %b", t2);
            $finish;
        end

        // Test Scenario 3: One driver 0 (wired-AND)
        if (t3 !== 1'b0) begin
            $display("FAIL: Scenario 3 - Triand (1 & 0) expected 0, got %b", t3);
            $finish;
        end

        // Test Scenario 4: One driver Z (1 & Z = 1)
        if (t4 !== 1'b1) begin
            $display("FAIL: Scenario 4 - Triand (1 & z) expected 1, got %b", t4);
            $finish;
        end
        en4 = 1;
        #1;
        // (1 & 0 = 0)
        if (t4 !== 1'b0) begin
            $display("FAIL: Scenario 4 - Triand (1 & 0) expected 0, got %b", t4);
            $finish;
        end

        // Test Scenario 5: Multi-bit triand (1111 & 1100 = 1100)
        if (t5 !== 4'b1100) begin
            $display("FAIL: Scenario 5 - Multi-bit triand expected 1100, got %b", t5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
