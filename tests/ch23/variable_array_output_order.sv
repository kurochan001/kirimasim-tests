`timescale 1ns/1ns
module variable_array_producer #(parameter bit WHOLE = 1)
                              (input bit clock, input logic signed [8:0] left, right,
                              output logic signed [8:0] data [5:4],
                              output wire [17:0] local_word);
  if (WHOLE) begin : whole_assignment
    always @(posedge clock) data <= '{left, right};
  end else begin : element_assignments
    always @(posedge clock) begin
      data[5] <= left;
      data[4] <= right;
    end
  end
  assign local_word = {data[5], data[4]};
endmodule

module variable_array_harness #(parameter bit WHOLE = 1);
  bit clock;
  logic signed [8:0] left, right;
  logic signed [8:0] matching [5:4], reversed [0:1];
  wire [17:0] first_local, second_local;

  variable_array_producer #(WHOLE) ordinary(clock, left, right, matching, first_local);
  variable_array_producer #(WHOLE) opposite(clock, left, right, reversed, second_local);

  task automatic send_words(input logic signed [8:0] left_word, right_word);
    left = left_word;
    right = right_word;
    #1 clock = 1;
    #1 $display("same=%0d/%0d reversed=%0d/%0d local=%b/%b",
                matching[5], matching[4], reversed[0], reversed[1],
                {matching[5], matching[4]} === first_local,
                {reversed[0], reversed[1]} === second_local);
    clock = 0;
  endtask

  initial begin
    send_words(-9'sd22, 9'sd160);
    send_words(9'sd63, -9'sd128);
    $finish(0);
  end
endmodule
