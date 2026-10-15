/*
:name: test_net_logic
:description: Logic type behavior
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 10.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_logic.expected
*/
// Logic type behavior
module test_net_logic;
    // Scenario 1: Logic as variable (procedural)
    logic l1;

    // Scenario 2: Logic as net (continuous assignment)
    logic l2;
    assign l2 = 1'b1;

    // Scenario 3: Multi-bit logic
    logic [7:0] l3;

    // Scenario 4: Logic with 4-state values
    logic [1:0] l4;

    // Scenario 5: Logic array
    logic [3:0] l5 [0:2];

    initial begin
        // Test Scenario 1: Logic as variable
        l1 = 1'b0;
        if (l1 !== 1'b0) begin
            $display("FAIL: Scenario 1 - Logic variable expected 0, got %b", l1);
            $finish;
        end
        l1 = 1'b1;
        if (l1 !== 1'b1) begin
            $display("FAIL: Scenario 1 - Logic variable expected 1, got %b", l1);
            $finish;
        end

        // Test Scenario 2: Logic with continuous assignment
        #1;
        if (l2 !== 1'b1) begin
            $display("FAIL: Scenario 2 - Logic continuous expected 1, got %b", l2);
            $finish;
        end

        // Test Scenario 3: Multi-bit logic
        l3 = 8'hAB;
        if (l3 !== 8'hAB) begin
            $display("FAIL: Scenario 3 - Multi-bit logic expected 0xAB, got 0x%h", l3);
            $finish;
        end

        // Test Scenario 4: Logic with X and Z
        l4 = 2'b01;
        if (l4 !== 2'b01) begin
            $display("FAIL: Scenario 4 - Logic 4-state expected 01, got %b", l4);
            $finish;
        end
        l4 = 2'bxz;
        if (l4 !== 2'bxz) begin
            $display("FAIL: Scenario 4 - Logic 4-state expected xz, got %b", l4);
            $finish;
        end

        // Test Scenario 5: Logic array
        l5[0] = 4'h1;
        l5[1] = 4'h2;
        l5[2] = 4'h3;
        if (l5[0] !== 4'h1 || l5[1] !== 4'h2 || l5[2] !== 4'h3) begin
            $display("FAIL: Scenario 5 - Logic array expected 1/2/3, got %h/%h/%h", l5[0], l5[1], l5[2]);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
