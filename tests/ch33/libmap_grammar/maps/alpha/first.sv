`include "cell_value.svh"
module alpha_first(output wire [7:0] value);
  localparam logic [7:0] VALUE = `LIBMAP_CELL_VALUE;
  assign value = VALUE;
endmodule
`undef LIBMAP_CELL_VALUE
