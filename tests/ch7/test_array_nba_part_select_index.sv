/*
:name: test_array_nba_part_select_index
:description: A FIFO whose memory is written with a nonblocking assignment indexed by a part-select of the pointer
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.6 10.4.2 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_nba_part_select_index.expected
*/
`timescale 1ns/1ps

module test_array_nba_part_select_index;
  localparam int DEPTH = 4;
  localparam int WIDTH = 8;

  logic clk = 0;
  logic rst_n;
  logic push;
  logic pop;
  logic [WIDTH-1:0] din;
  logic [WIDTH-1:0] dout;
  logic full;
  logic empty;

  logic [WIDTH-1:0] mem [0:DEPTH-1];
  logic [$clog2(DEPTH):0] wr_ptr;
  logic [$clog2(DEPTH):0] rd_ptr;
  logic [$clog2(DEPTH):0] count;

  always #5 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
      count <= '0;
    end else begin
      case ({push && !full, pop && !empty})
        2'b10: begin
          mem[wr_ptr[$clog2(DEPTH)-1:0]] <= din;
          wr_ptr <= wr_ptr + 1;
          count <= count + 1;
        end
        2'b01: begin
          rd_ptr <= rd_ptr + 1;
          count <= count - 1;
        end
        default: ;
      endcase
    end
  end

  assign dout = mem[rd_ptr[$clog2(DEPTH)-1:0]];
  assign full = (count == DEPTH);
  assign empty = (count == 0);

  initial begin
    rst_n = 0;
    push = 0;
    pop = 0;
    din = '0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
    #1;

    for (int i = 0; i < DEPTH; i++) begin
      din = 8'hA0 + i;
      push = 1;
      pop = 0;
      @(posedge clk);
      #1;
    end

    push = 0;
    @(posedge clk);
    #1;

    if (full !== 1'b1 || empty !== 1'b0) begin
      $fatal(1, "TEST FAILED: fifo flags full=%0b empty=%0b", full, empty);
    end

    for (int i = 0; i < DEPTH; i++) begin
      pop = 1;
      if (dout !== (8'hA0 + i)) begin
        $fatal(1, "TEST FAILED: pop %0d expected %02h got %02h", i, 8'hA0 + i, dout);
      end
      @(posedge clk);
      #1;
    end

    pop = 0;
    @(posedge clk);
    #1;

    if (empty !== 1'b1) begin
      $fatal(1, "TEST FAILED: fifo did not return empty");
    end

    $display("TEST PASSED: array NBA with part-select index");
    $finish;
  end
endmodule
