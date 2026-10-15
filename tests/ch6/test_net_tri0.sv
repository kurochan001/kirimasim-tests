/*
:name: test_net_tri0
:description: Tri0 net type (pulls to 0 when floating)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.5
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_tri0.expected
*/
// Tri0 net type (pulls to 0 when floating)
module test_net_tri0;
    // Scenario 1: Undriven tri0 (should be 0)
    tri0 t1;

    // Scenario 2: Driven tri0
    tri0 t2;
    assign t2 = 1'b1;

    // Scenario 3: Tri0 with conditional driver
    tri0 t3;
    reg en3;
    assign t3 = en3 ? 1'b1 : 1'bz;

    // Scenario 4: Multi-bit tri0
    tri0 [3:0] t4;
    reg en4;
    assign t4 = en4 ? 4'b1111 : 4'bzzzz;

    // Scenario 5: Tri0 toggles
    tri0 t5;
    reg drv5;
    reg en5;
    assign t5 = en5 ? drv5 : 1'bz;

    initial begin
        en3 = 0;
        en4 = 0;
        en5 = 0;
        drv5 = 0;
        #1;

        // Test Scenario 1: Undriven tri0 pulls to 0
        if (t1 !== 1'b0) begin
            $display("FAIL: Scenario 1 - Undriven tri0 expected 0, got %b", t1);
            $finish;
        end

        // Test Scenario 2: Driven tri0
        if (t2 !== 1'b1) begin
            $display("FAIL: Scenario 2 - Driven tri0 expected 1, got %b", t2);
            $finish;
        end

        // Test Scenario 3: Conditional driver disabled (pulls to 0)
        if (t3 !== 1'b0) begin
            $display("FAIL: Scenario 3 - Tri0 disabled expected 0, got %b", t3);
            $finish;
        end
        en3 = 1;
        #1;
        if (t3 !== 1'b1) begin
            $display("FAIL: Scenario 3 - Tri0 enabled expected 1, got %b", t3);
            $finish;
        end

        // Test Scenario 4: Multi-bit tri0 disabled (all 0)
        if (t4 !== 4'b0000) begin
            $display("FAIL: Scenario 4 - Multi-bit tri0 disabled expected 0000, got %b", t4);
            $finish;
        end
        en4 = 1;
        #1;
        if (t4 !== 4'b1111) begin
            $display("FAIL: Scenario 4 - Multi-bit tri0 enabled expected 1111, got %b", t4);
            $finish;
        end

        // Test Scenario 5: Toggle between driven and pull-down
        if (t5 !== 1'b0) begin
            $display("FAIL: Scenario 5 - Tri0 initial expected 0, got %b", t5);
            $finish;
        end
        en5 = 1;
        drv5 = 1;
        #1;
        if (t5 !== 1'b1) begin
            $display("FAIL: Scenario 5 - Tri0 driven 1 expected 1, got %b", t5);
            $finish;
        end
        en5 = 0;
        #1;
        if (t5 !== 1'b0) begin
            $display("FAIL: Scenario 5 - Tri0 released expected 0, got %b", t5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
