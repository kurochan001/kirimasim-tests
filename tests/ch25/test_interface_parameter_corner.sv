/*
:name: test_interface_parameter_corner
:description: Tests parameterized interfaces and generic interface patterns
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.8 25.5 4.9.4 10.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_parameter_corner.expected
*/
// Tests parameterized interfaces and generic interface patterns
`timescale 1ns/1ps

interface data_bus_if #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4
);
    logic clk;
    logic [WIDTH-1:0] data;
    logic [$clog2(DEPTH)-1:0] addr;
    logic wr_en;
    logic rd_en;
    logic [WIDTH-1:0] rd_data;

    modport master (
        input clk, rd_data,
        output data, addr, wr_en, rd_en
    );

    modport slave (
        input clk, data, addr, wr_en, rd_en,
        output rd_data
    );
endinterface

module memory #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4
) (
    data_bus_if.slave bus
);
    logic [WIDTH-1:0] mem [DEPTH];

    always @(posedge bus.clk) begin
        if (bus.wr_en) begin
            mem[bus.addr] <= bus.data;
        end
        if (bus.rd_en) begin
            bus.rd_data <= mem[bus.addr];
        end
    end
endmodule

module test_interface_parameter_corner;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;

    // Clock generation
    always #5 clk = ~clk;

    // Different sized interfaces
    data_bus_if #(.WIDTH(8), .DEPTH(16)) bus8();
    data_bus_if #(.WIDTH(16), .DEPTH(8)) bus16();
    data_bus_if #(.WIDTH(32), .DEPTH(4)) bus32();

    // Connect clocks
    assign bus8.clk = clk;
    assign bus16.clk = clk;
    assign bus32.clk = clk;

    // Memory instances
    memory #(.WIDTH(8), .DEPTH(16)) mem8 (.bus(bus8.slave));
    memory #(.WIDTH(16), .DEPTH(8)) mem16 (.bus(bus16.slave));
    memory #(.WIDTH(32), .DEPTH(4)) mem32 (.bus(bus32.slave));

    // The test drives the buses with nonblocking assignments: the memories
    // sample them at the same clock edge at which the test resumes

    // Test 8-bit interface
    task test_8bit_interface();
        bus8.wr_en <= 1;
        bus8.rd_en <= 0;
        bus8.addr <= 0;
        bus8.data <= 8'hAB;
        @(posedge clk);

        bus8.wr_en <= 0;
        bus8.rd_en <= 1;
        @(posedge clk);
        @(posedge clk);

        if (bus8.rd_data == 8'hAB) begin
            $display("PASS: 8-bit parameterized interface works");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit interface read back 0x%h", bus8.rd_data);
            fail_count++;
        end

        bus8.rd_en <= 0;
    endtask

    // Test 16-bit interface
    task test_16bit_interface();
        bus16.wr_en <= 1;
        bus16.rd_en <= 0;
        bus16.addr <= 3;
        bus16.data <= 16'hCAFE;
        @(posedge clk);

        bus16.wr_en <= 0;
        bus16.rd_en <= 1;
        @(posedge clk);
        @(posedge clk);

        if (bus16.rd_data == 16'hCAFE) begin
            $display("PASS: 16-bit parameterized interface works");
            pass_count++;
        end else begin
            $display("FAIL: 16-bit interface read back 0x%h", bus16.rd_data);
            fail_count++;
        end

        bus16.rd_en <= 0;
    endtask

    // Test 32-bit interface
    task test_32bit_interface();
        bus32.wr_en <= 1;
        bus32.rd_en <= 0;
        bus32.addr <= 2;
        bus32.data <= 32'hDEADBEEF;
        @(posedge clk);

        bus32.wr_en <= 0;
        bus32.rd_en <= 1;
        @(posedge clk);
        @(posedge clk);

        if (bus32.rd_data == 32'hDEADBEEF) begin
            $display("PASS: 32-bit parameterized interface works");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit interface read back 0x%h", bus32.rd_data);
            fail_count++;
        end

        bus32.rd_en <= 0;
    endtask

    // Test multiple writes and reads
    task test_multiple_ops();
        int i;

        // Write to 8-bit bus
        for (i = 0; i < 4; i++) begin
            bus8.wr_en <= 1;
            bus8.rd_en <= 0;
            bus8.addr <= i;
            bus8.data <= i * 16;
            @(posedge clk);
        end
        bus8.wr_en <= 0;

        // Read back
        for (i = 0; i < 4; i++) begin
            bus8.rd_en <= 1;
            bus8.addr <= i;
            @(posedge clk);
            @(posedge clk);
            if (bus8.rd_data != i * 16) begin
                $display("FAIL: Multiple ops read mismatch at addr %0d", i);
                fail_count++;
                return;
            end
        end
        bus8.rd_en <= 0;

        $display("PASS: Multiple write/read operations work");
        pass_count++;
    endtask

    initial begin
        $display("=== Parameterized Interface Test ===");

        // Initialize
        bus8.wr_en <= 0; bus8.rd_en <= 0; bus8.addr <= 0; bus8.data <= 0;
        bus16.wr_en <= 0; bus16.rd_en <= 0; bus16.addr <= 0; bus16.data <= 0;
        bus32.wr_en <= 0; bus32.rd_en <= 0; bus32.addr <= 0; bus32.data <= 0;

        repeat (3) @(posedge clk);

        test_8bit_interface();
        test_16bit_interface();
        test_32bit_interface();
        test_multiple_ops();

        repeat (3) @(posedge clk);

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
