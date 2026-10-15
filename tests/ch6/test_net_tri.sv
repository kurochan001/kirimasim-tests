/*
:name: test_net_tri
:description: Tri net type (tri-state)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_tri.expected
*/
// Tri net type (tri-state)
module test_net_tri;
    // Scenario 1: Single driver tri
    tri t1;
    assign t1 = 1'b1;

    // Scenario 2: Tri with high-impedance
    tri t2;
    reg en2;
    assign t2 = en2 ? 1'b1 : 1'bz;

    // Scenario 3: Multi-bit tri
    tri [7:0] t3;
    assign t3 = 8'hCD;

    // Scenario 4: Tri with multiple drivers (one Z)
    tri t4;
    reg en4a, en4b;
    assign t4 = en4a ? 1'b1 : 1'bz;
    assign t4 = en4b ? 1'b0 : 1'bz;

    // Scenario 5: Tri bus
    tri [3:0] t5;
    reg [3:0] drv5;
    reg en5;
    assign t5 = en5 ? drv5 : 4'bzzzz;

    initial begin
        en2 = 0;
        en4a = 0;
        en4b = 0;
        en5 = 0;
        drv5 = 4'b0000;
        #1;

        // Test Scenario 1: Single driver
        if (t1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Single driver tri expected 1, got %b", t1);
            $finish;
        end

        // Test Scenario 2: Disabled driver (Z)
        if (t2 !== 1'bz) begin
            $display("FAIL: Scenario 2 - Tri disabled expected z, got %b", t2);
            $finish;
        end
        en2 = 1;
        #1;
        if (t2 !== 1'b1) begin
            $display("FAIL: Scenario 2 - Tri enabled expected 1, got %b", t2);
            $finish;
        end

        // Test Scenario 3: Multi-bit tri
        if (t3 !== 8'hCD) begin
            $display("FAIL: Scenario 3 - Multi-bit tri expected 0xCD, got 0x%h", t3);
            $finish;
        end

        // Test Scenario 4: Both drivers Z
        if (t4 !== 1'bz) begin
            $display("FAIL: Scenario 4 - Tri both Z expected z, got %b", t4);
            $finish;
        end
        en4a = 1;
        #1;
        if (t4 !== 1'b1) begin
            $display("FAIL: Scenario 4 - Tri driver A expected 1, got %b", t4);
            $finish;
        end
        en4a = 0;
        en4b = 1;
        #1;
        if (t4 !== 1'b0) begin
            $display("FAIL: Scenario 4 - Tri driver B expected 0, got %b", t4);
            $finish;
        end

        // Test Scenario 5: Tri bus
        if (t5 !== 4'bzzzz) begin
            $display("FAIL: Scenario 5 - Tri bus disabled expected zzzz, got %b", t5);
            $finish;
        end
        drv5 = 4'b1010;
        en5 = 1;
        #1;
        if (t5 !== 4'b1010) begin
            $display("FAIL: Scenario 5 - Tri bus enabled expected 1010, got %b", t5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
