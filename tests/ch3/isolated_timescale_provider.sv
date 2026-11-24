`timescale 10ns/1ns

module directive_delay(output bit done);
  initial #1.24 done = 1;
endmodule
