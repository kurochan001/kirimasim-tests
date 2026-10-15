/*
:name: test_net_wire
:description: Wire net type
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_wire.expected
*/
// Wire net type
module test_net_wire;
    // Scenario 1: Basic wire declaration and assignment
    wire w1;
    assign w1 = 1'b1;

    // Scenario 2: Multi-bit wire
    wire [7:0] w2;
    assign w2 = 8'hA5;

    // Scenario 3: Another single-driver wire
    wire w3;
    assign w3 = 1'b1;

    // Scenario 4: Wire array
    wire [3:0] w4 [0:1];
    assign w4[0] = 4'b1010;
    assign w4[1] = 4'b0101;

    // Scenario 5: Wire with conditional assignment
    reg sel;
    wire w5;
    assign w5 = sel ? 1'b1 : 1'b0;

    initial begin
        sel = 0;
        #1;

        // Test Scenario 1
        if (w1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Basic wire expected 1, got %b", w1);
            $finish;
        end

        // Test Scenario 2
        if (w2 !== 8'hA5) begin
            $display("FAIL: Scenario 2 - Multi-bit wire expected 0xA5, got 0x%h", w2);
            $finish;
        end

        // Test Scenario 3
        if (w3 !== 1'b1) begin
            $display("FAIL: Scenario 3 - Wire expected 1, got %b", w3);
            $finish;
        end

        // Test Scenario 4
        if (w4[0] !== 4'b1010 || w4[1] !== 4'b0101) begin
            $display("FAIL: Scenario 4 - Wire array expected 1010/0101, got %b/%b", w4[0], w4[1]);
            $finish;
        end

        // Test Scenario 5
        if (w5 !== 1'b0) begin
            $display("FAIL: Scenario 5 - Conditional wire expected 0, got %b", w5);
            $finish;
        end

        sel = 1;
        #1;
        if (w5 !== 1'b1) begin
            $display("FAIL: Scenario 5 - Conditional wire expected 1 after sel=1, got %b", w5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
