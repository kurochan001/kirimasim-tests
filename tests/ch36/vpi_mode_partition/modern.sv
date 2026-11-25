`timescale 1ns/1ns

module vpi_mode_modern_partition;
  class sample;
    int value;
  endclass

  sample element;
  real readings[0:1];

  initial begin
    element = new;
    element.value = 29;
    readings[1] = 2.75;
  end
endmodule
