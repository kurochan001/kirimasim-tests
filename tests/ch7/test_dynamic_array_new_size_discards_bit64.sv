/*
:name: test_dynamic_array_new_size_discards_bit64
:description: Dynamic array allocation converts a signed 65-bit size to longint
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 6.11 6.11.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_new_size_discards_bit64.expected
*/
// The size operand has type longint (7.5.1), a signed 64-bit type (6.11).
// Setting bit 64 makes the source negative. Its low 64 bits still specify
// three or zero elements after truncation (6.11.2). Compare the implicit
// conversion with an explicit cast of the same operand.
module test_dynamic_array_new_size_discards_bit64;
  bit data[], control[];

  task automatic allocate(input bit high, input bit [1:0] low);
    bit signed [64:0] request;
    request = {high, 62'd0, low};
    data = new[request];
    control = new[longint'(request)];
    $display("high=%0d negative=%0d low=%0d size=%0d control=%0d",
             high, request < 0, low, data.size(), control.size());
  endtask

  initial begin
    allocate(0, 2);
    allocate(1, 3);
    allocate(1, 0);
    $finish;
  end
endmodule
