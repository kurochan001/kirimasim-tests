/*
:name: test_generate_bitselect_literal
:description: This pattern is used in NVDLA RAM behavioral models
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate_bitselect_literal.expected
*/
// This pattern is used in NVDLA RAM behavioral models

module ram_model #(parameter WIDTH = 8, parameter DEPTH = 4) (
    input  logic                     clk,
    input  logic                     we,
    input  logic [$clog2(DEPTH)-1:0] addr,
    input  logic [WIDTH-1:0]         wdata,
    output logic [WIDTH-1:0]         rdata
);
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // Pattern from NVDLA: literal bit-select in parameter expression
    localparam logic [5:0] INIT_PATTERN = 6'b101010;
    localparam bit BIT0 = INIT_PATTERN[0];   // bit-select on literal
    localparam bit BIT1 = INIT_PATTERN[1];
    localparam bit BIT5 = INIT_PATTERN[5];

    // Contention detection pattern from NVDLA RAM models
    localparam logic [WIDTH-1:0] ZERO_PATTERN = {WIDTH{1'b0}};

    always_ff @(posedge clk) begin
        if (we) mem[addr] <= wdata;
    end

    assign rdata = mem[addr];

    // Verify bit-select results
    initial begin
        // BIT0 should be 0 (bit 0 of 101010)
        if (BIT0 !== 1'b0) begin
            $display("FAIL: BIT0 = %b, expected 0", BIT0);
            $fatal;
        end
        // BIT1 should be 1 (bit 1 of 101010)
        if (BIT1 !== 1'b1) begin
            $display("FAIL: BIT1 = %b, expected 1", BIT1);
            $fatal;
        end
        // BIT5 should be 1 (bit 5 of 101010)
        if (BIT5 !== 1'b1) begin
            $display("FAIL: BIT5 = %b, expected 1", BIT5);
            $fatal;
        end
        $display("TEST PASSED: generate literal bit-select");
        $finish;
    end
endmodule

module test_generate_bitselect_literal;
    logic clk = 0;
    always #5 clk = ~clk;

    logic we, rdata;
    logic [7:0] wdata;
    logic [1:0] addr;
    logic [7:0] rd;

    ram_model #(.WIDTH(8), .DEPTH(4)) dut (
        .clk(clk), .we(we), .addr(addr), .wdata(wdata), .rdata(rd)
    );
endmodule
