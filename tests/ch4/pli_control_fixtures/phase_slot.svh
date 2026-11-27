`timescale 1ns/1ns
module region_control_top;
  logic clk = 0;
  int level = `RC_INITIAL, completed = 0, p = 0, back = 0;
  wire [31:0] mirror = level * 2;
  bit go = 0;

  sequence ended;
    @(posedge clk) 1'b1;
  endsequence

  initial begin
    $observe_region_slot(`RC_TICK);
    #(`RC_TICK);
    $display("active t=%0d level=%0d", $time, level);
    level = `RC_ACTIVE;
    level <= `RC_NBA;
    clk = 1;
    #0 $display("inactive t=%0d level=%0d triggered=%0d", $time, level, ended.triggered);
    #3 $finish(0);
  end

  always @(level)
    if (level == `RC_NBA) begin
      completed = level + 4;
      $display("nba feedback t=%0d level=%0d completed=%0d triggered=%0d",
               $time, level, completed, ended.triggered);
    end

  a1: assert property (@(posedge clk) level == `RC_PROPERTY)
    begin
      $display("property t=%0d passed=1 sample=%0d level=%0d mirror=%0d triggered=%0d",
               $time, $sampled(level), level, mirror, ended.triggered);
      go = 1;
    end
  else begin
    $display("property t=%0d passed=0 sample=%0d level=%0d mirror=%0d triggered=%0d",
             $time, $sampled(level), level, mirror, ended.triggered);
    go = 1;
  end

  always @(p)
    if (p != 0) begin
      back = p;
      $display("active feedback t=%0d p=%0d back=%0d", $time, p, back);
    end

  region_control_program prg();
endmodule

program region_control_program;
  initial begin
    @(region_control_top.go);
    $display("reactive t=%0d p=%0d back=%0d", $time, region_control_top.p, region_control_top.back);
    #0 $display("re-inactive t=%0d p=%0d back=%0d", $time, region_control_top.p, region_control_top.back);
    region_control_top.p <= `RC_RENBA;
    #3;
  end

  initial begin
    @(region_control_top.p);
    $display("re-nba feedback t=%0d p=%0d back=%0d", $time, region_control_top.p, region_control_top.back);
    #3;
  end
endprogram

`undef RC_TICK
`undef RC_INITIAL
`undef RC_ACTIVE
`undef RC_NBA
`undef RC_RENBA
`undef RC_PROPERTY
