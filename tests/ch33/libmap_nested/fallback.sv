module root_cell(output wire [7:0] value);
  assign value = 81;
endmodule

module middle_cell(output wire [7:0] value);
  assign value = 82;
endmodule

module inner_cell(output wire [7:0] value);
  assign value = 83;
endmodule
