`include "extra_value.svh"
module alpha_second(output wire [7:0] value);
  localparam logic [7:0] VALUE = `LIBMAP_EXTRA_VALUE;
  assign value = VALUE;
endmodule
`undef LIBMAP_EXTRA_VALUE
