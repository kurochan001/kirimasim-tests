module partition_lane(input wire [1:0] data, output wire [1:0] result);
  assign result = {data[0], data[1]};
endmodule
