/*
:name: test_net_uwire
:description: Uwire net type (unresolved wire - single driver only)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_uwire.expected
*/
// Uwire net type (unresolved wire - single driver only)
module test_net_uwire;
    // Scenario 1: Basic uwire
    uwire u1;
    assign u1 = 1'b1;

    // Scenario 2: Multi-bit uwire
    uwire [7:0] u2;
    assign u2 = 8'hAB;

    // Scenario 3: Uwire with conditional
    reg sel;
    uwire u3;
    assign u3 = sel ? 1'b1 : 1'b0;

    // Scenario 4: Uwire array
    uwire [3:0] u4 [0:1];
    assign u4[0] = 4'b1100;
    assign u4[1] = 4'b0011;

    // Scenario 5: Uwire in expression
    uwire u5;
    assign u5 = 1'b1;
    wire w5;
    assign w5 = u5 ^ 1'b1;

    initial begin
        sel = 0;
        #1;

        // Test Scenario 1: Basic uwire
        if (u1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Basic uwire expected 1, got %b", u1);
            $finish;
        end

        // Test Scenario 2: Multi-bit uwire
        if (u2 !== 8'hAB) begin
            $display("FAIL: Scenario 2 - Multi-bit uwire expected 0xAB, got 0x%h", u2);
            $finish;
        end

        // Test Scenario 3: Uwire with conditional
        if (u3 !== 1'b0) begin
            $display("FAIL: Scenario 3 - Uwire conditional expected 0, got %b", u3);
            $finish;
        end
        sel = 1;
        #1;
        if (u3 !== 1'b1) begin
            $display("FAIL: Scenario 3 - Uwire conditional expected 1, got %b", u3);
            $finish;
        end

        // Test Scenario 4: Uwire array
        if (u4[0] !== 4'b1100 || u4[1] !== 4'b0011) begin
            $display("FAIL: Scenario 4 - Uwire array expected 1100/0011, got %b/%b", u4[0], u4[1]);
            $finish;
        end

        // Test Scenario 5: Uwire in expression (1 ^ 1 = 0)
        if (w5 !== 1'b0) begin
            $display("FAIL: Scenario 5 - Uwire XOR 1 expected 0, got %b", w5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
