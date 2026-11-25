`timescale 1ns/1ns

module vpi_mode_compatible_top;
  vpi_mode_legacy_partition legacy();
  initial #1 $display("hdl legacy=%0d", legacy.scalar);
endmodule
