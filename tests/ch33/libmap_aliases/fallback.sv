module no_dot_decoy(output wire [7:0] value);
  assign value = 8'd67;
endmodule

module with_dot_decoy(output wire [7:0] value);
  assign value = 8'd67;
endmodule

module slash_nested(output wire [7:0] value);
  assign value = 8'd53;
endmodule

module star_nested(output wire [7:0] value);
  assign value = 8'd53;
endmodule
