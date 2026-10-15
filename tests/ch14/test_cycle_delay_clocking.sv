/*
:name: test_cycle_delay_clocking
:description: Test cycle delay (##N) in clocking blocks
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.11 14.12 14.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cycle_delay_clocking.expected
*/
// Test cycle delay (##N) in clocking blocks

module test_cycle_delay_clocking;
    logic clk = 0;
    logic [7:0] data = 0;
    logic valid = 0;
    logic ready = 1;
    int cycle_count = 0;

    // Clock generation
    always #5 clk = ~clk;

    // Count clock cycles
    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
        $display("[%0t] Cycle %0d: data=%h, valid=%b, ready=%b",
                 $time, cycle_count, data, valid, ready);
    end

    // Clocking block definition
    clocking cb @(posedge clk);
        output data;
        output valid;
        input  ready;
    endclocking

    // Set as default clocking
    default clocking cb;

    // Test with clocking block
    initial begin
        $display("=== Clocking Block Cycle Delay Test ===");

        // Wait for first clock edge
        @(cb);

        // Send first data with ##1 delay
        cb.data <= 8'hAA;
        cb.valid <= 1'b1;
        ##1;  // Wait 1 cycle in clocking block context

        // Send second data
        cb.data <= 8'hBB;
        ##1;

        // Clear valid with ##2 delay
        cb.valid <= 1'b0;
        ##2;  // Wait 2 cycles

        // Send third data
        cb.data <= 8'hCC;
        cb.valid <= 1'b1;
        ##1;

        cb.valid <= 1'b0;
        ##1;

        // The counting always block runs at the same edge; read after it
        #1;
        $display("\n=== Test Complete ===");
        $display("Total cycles: %0d", cycle_count);

        // @(cb) plus 1 + 1 + 2 + 1 + 1 cycle delays: the 7th edge
        if (cycle_count == 7) begin
            $display("PASS: Clocking block cycle delays executed");
        end else begin
            $display("FAIL: expected 7 cycles");
        end

        $finish;
    end
endmodule
