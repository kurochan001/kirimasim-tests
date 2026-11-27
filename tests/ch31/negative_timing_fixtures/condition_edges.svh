`timescale 1ns/1ns
module timing_conditions_cell #(parameter int FIRST = -2, SECOND = 6)
    (input wire clock, data, stamp, check_now);
  wire shifted_clock, shifted_data;
  reg notifier = 0;
  // Begin tested timing check
  specify
`ifdef TCK_SETUPHOLD
    $setuphold(posedge clock, posedge data, FIRST, SECOND, notifier,
               stamp, check_now, shifted_clock, shifted_data);
`else
    $recrem(posedge data, posedge clock, FIRST, SECOND, notifier,
            stamp, check_now, shifted_data, shifted_clock);
`endif
  endspecify
  // End tested timing check
endmodule

module timing_conditions_guard(input wire clock, output wire delayed_clock);
  wire delayed_data;
  wire quiet = 1'b0;
  // Begin guard timing check
  specify
`ifdef TCK_SETUPHOLD
    $setuphold(posedge clock, quiet, -8, 12, , , , delayed_clock, delayed_data);
`else
    $recrem(quiet, posedge clock, -8, 12, , , , delayed_data, delayed_clock);
`endif
  endspecify
  // End guard timing check
endmodule

module timing_conditions_top;
  bit clock, early, late, near_before, near_after;
  bit pre_stamp, pre_check, post_stamp, post_check;
  wire delayed_guard;
  wire raw_condition = !clock;
  wire explicit_condition = !delayed_guard;

  timing_conditions_guard guard_path(clock, delayed_guard);
  timing_conditions_cell #(6, -2) pre_valid(clock, early, pre_stamp, pre_check);
  timing_conditions_cell #(6, -2) pre_swapped(clock, early, pre_check, pre_stamp);
  timing_conditions_cell #(6, -2) pre_outside(clock, near_before, 1'b1, 1'b1);
  timing_conditions_cell post_valid(clock, late, post_stamp, post_check);
  timing_conditions_cell post_swapped(clock, late, post_check, post_stamp);
  timing_conditions_cell post_outside(clock, near_after, 1'b1, 1'b1);
  timing_conditions_cell post_explicit(clock, late, 1'b1, explicit_condition);
  timing_conditions_cell post_raw(clock, late, 1'b1, raw_condition);

  initial begin
    #16 early = 1;
    #1 $display("early data=%b delayed=%b", early, pre_valid.shifted_data);
    pre_stamp = 1;
    #2 pre_stamp = 0;
    pre_check = 1;
    near_before = 1;
    #1 clock = 1;
    #1 $display("clock raw=%b delayed=%b", clock, post_valid.shifted_clock);
    near_after = 1;
    post_stamp = 1;
    #2 post_stamp = 0;
    post_check = 1;
    #1 late = 1;
    #1 $display("condition raw=%b explicit=%b", raw_condition, explicit_condition);
    #5;
    $display("before valid=%b swapped=%b outside=%b",
             pre_valid.notifier, pre_swapped.notifier, pre_outside.notifier);
    $display("after valid=%b swapped=%b outside=%b explicit=%b raw=%b",
             post_valid.notifier, post_swapped.notifier, post_outside.notifier,
             post_explicit.notifier, post_raw.notifier);
    $finish(0);
  end
endmodule

`undef TCK_SETUPHOLD
`undef TCK_RECREM
