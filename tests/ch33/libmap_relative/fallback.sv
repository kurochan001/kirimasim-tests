module local_cell(output wire [7:0] value);
  assign value = 91;
endmodule

module parent_cell(output wire [7:0] value);
  assign value = 92;
endmodule
