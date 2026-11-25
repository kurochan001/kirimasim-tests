/*
:name: test_dpi_packed_storage_conversion
:description: Packed structures and multidimensional arrays cross DPI through canonical words
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.2.1 35.5.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_packed_storage_conversion.c
:expected_stdout: @test_dpi_packed_storage_conversion.expected
*/
module test_dpi_packed_storage_conversion;
  typedef struct packed { bit [1:0] hi; bit [31:0] lo; } bit_record;
  typedef bit [1:0][16:0] bit_grid;
  typedef struct packed { logic [1:0] hi; logic [31:0] lo; } logic_record;
  typedef logic [1:0][16:0] logic_grid;

  import "DPI-C" function void transfer_bit_record(input bit_record src, output bit_record dst);
  import "DPI-C" function void transfer_bit_grid(input bit_grid src, output bit_grid dst);
  import "DPI-C" function void transfer_logic_record(input logic_record src,
                                                    output logic_record dst);
  import "DPI-C" function void transfer_logic_grid(input logic_grid src, output logic_grid dst);

`ifdef DPI_PACKED_UNKNOWN
  localparam logic [33:0] LOGIC_INPUT = {2'bxz, 32'h02x3_456z};
  localparam logic [33:0] LOGIC_REPLY = {2'bzx, 32'h02x3_457z};
`else
  localparam logic [33:0] LOGIC_INPUT = {2'b10, 32'h02f3_4560};
  localparam logic [33:0] LOGIC_REPLY = {2'b10, 32'h02f3_4570};
`endif

  bit_record bit_record_src, bit_record_dst;
  bit_grid bit_grid_src, bit_grid_dst;
  logic_record logic_record_src, logic_record_dst;
  logic_grid logic_grid_src, logic_grid_dst;

  initial begin
    int form;
    if (!$value$plusargs("form=%d", form)) form = -1;
    if (form == -1 || form == 0) begin
      bit_record_src = {2'b10, 32'h02f3_4560};
      transfer_bit_record(bit_record_src, bit_record_dst);
      $display("bit record reply=%0d", bit_record_dst === {2'b10, 32'h02f3_4570});
    end
    if (form == -1 || form == 1) begin
      bit_grid_src = {2'b10, 32'h02f3_4560};
      transfer_bit_grid(bit_grid_src, bit_grid_dst);
      $display("bit grid reply=%0d", bit_grid_dst === {2'b10, 32'h02f3_4570});
    end
    if (form == -1 || form == 2) begin
      logic_record_src = LOGIC_INPUT;
      transfer_logic_record(logic_record_src, logic_record_dst);
      $display("logic record reply=%0d", logic_record_dst === LOGIC_REPLY);
    end
    if (form == -1 || form == 3) begin
      logic_grid_src = LOGIC_INPUT;
      transfer_logic_grid(logic_grid_src, logic_grid_dst);
      $display("logic grid reply=%0d", logic_grid_dst === LOGIC_REPLY);
    end
  end
endmodule
