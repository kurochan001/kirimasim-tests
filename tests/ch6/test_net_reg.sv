/*
:name: test_net_reg
:description: Reg variable type
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_reg.expected
*/
// Reg variable type
module test_net_reg;
    // Scenario 1: Basic reg declaration and assignment
    reg r1;

    // Scenario 2: Multi-bit reg
    reg [7:0] r2;

    // Scenario 3: Reg initialized to X
    reg r3;

    // Scenario 4: Reg array
    reg [3:0] r4 [0:1];

    // Scenario 5: Reg with procedural assignment
    reg [15:0] r5;

    initial begin
        // Test Scenario 1: Basic reg
        r1 = 1'b1;
        if (r1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Basic reg expected 1, got %b", r1);
            $finish;
        end

        // Test Scenario 2: Multi-bit reg
        r2 = 8'hFF;
        if (r2 !== 8'hFF) begin
            $display("FAIL: Scenario 2 - Multi-bit reg expected 0xFF, got 0x%h", r2);
            $finish;
        end
        r2 = 8'h00;
        if (r2 !== 8'h00) begin
            $display("FAIL: Scenario 2 - Multi-bit reg expected 0x00, got 0x%h", r2);
            $finish;
        end

        // Test Scenario 3: Reg toggle
        r3 = 1'b0;
        r3 = ~r3;
        if (r3 !== 1'b1) begin
            $display("FAIL: Scenario 3 - Reg toggle expected 1, got %b", r3);
            $finish;
        end

        // Test Scenario 4: Reg array
        r4[0] = 4'b1111;
        r4[1] = 4'b0000;
        if (r4[0] !== 4'b1111 || r4[1] !== 4'b0000) begin
            $display("FAIL: Scenario 4 - Reg array expected 1111/0000, got %b/%b", r4[0], r4[1]);
            $finish;
        end

        // Test Scenario 5: Reg procedural update
        r5 = 16'h1234;
        r5 = r5 + 16'h0001;
        if (r5 !== 16'h1235) begin
            $display("FAIL: Scenario 5 - Reg procedural expected 0x1235, got 0x%h", r5);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
