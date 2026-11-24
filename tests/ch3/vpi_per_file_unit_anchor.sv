int unit_marker = 23;

module vpi_per_file_unit_peer;
  wire [31:0] observed = $unit::unit_marker;
endmodule
