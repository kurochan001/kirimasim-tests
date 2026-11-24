/*
:name: test_bind_actual_can_reference_sibling_from_either_source_order
:description: Dependent bind port actuals resolve a bound sibling in either statement order
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_actual_can_reference_sibling_from_either_source_order.expected
*/
module bound_order_producer(input wire [7:0] seed, output wire [7:0] value);
  assign value = seed + 8'd5;
endmodule

module bound_order_consumer(input wire [7:0] source, output wire [7:0] observed);
  assign observed = source ^ 8'ha5;
endmodule

module bound_order_producer_first(input wire [7:0] seed, output wire [7:0] result);
  bind bound_order_producer_first bound_order_producer origin(seed, );
  bind bound_order_producer_first bound_order_consumer receiver(origin.value, result);
endmodule

module bound_order_consumer_first(input wire [7:0] seed, output wire [7:0] result);
  bind bound_order_consumer_first bound_order_consumer receiver(origin.value, result);
  bind bound_order_consumer_first bound_order_producer origin(seed, );
endmodule

module test_bind_actual_can_reference_sibling_from_either_source_order;
  bit [7:0] seed;
  wire [7:0] forward, reverse_order;
  bound_order_producer_first forward_cell(seed, forward);
  bound_order_consumer_first reverse_cell(seed, reverse_order);

  initial begin
    seed = 8'h10;
    #1 $display("initial forward=%h reverse=%h", forward, reverse_order);
    seed = 8'h38;
    #1 $display("changed forward=%h reverse=%h", forward, reverse_order);
    $finish(0);
  end
endmodule
