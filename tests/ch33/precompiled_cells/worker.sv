module phase_worker(output wire [7:0] value);
  wire [3:0] low;
  phase_leaf implementation(.value(low));
  assign value = {4'hA, low};
endmodule
