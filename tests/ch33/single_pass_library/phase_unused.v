`timescale 1ns/1ns
module phase_unused;
  initial $fatal(1, "unused library cell was elaborated");
endmodule
