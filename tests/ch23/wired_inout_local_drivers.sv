module local_and_drivers(input wire a, b, inout wand port_n, output wire local_read);
  assign port_n = a;
  assign port_n = b;
  assign local_read = port_n;
endmodule

module local_or_drivers(input wire a, b, inout wor port_n, output wire local_read);
  assign port_n = a;
  assign port_n = b;
  assign local_read = port_n;
endmodule

module remote_and_reader(inout wand port_n, output wire remote_read);
  assign remote_read = port_n;
endmodule

module remote_or_reader(inout wor port_n, output wire remote_read);
  assign remote_read = port_n;
endmodule
