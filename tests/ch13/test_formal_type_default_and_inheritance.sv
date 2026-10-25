/*
:name: test_formal_type_default_and_inheritance
:description: A task or function formal without a data type is logic when it is the first one or has its own direction, and otherwise takes the type of the formal before it (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_formal_type_default_and_inheritance.expected
*/
// IEEE 1800-2023 §13.3 (tasks) and §13.4 (functions): a formal argument
// whose data type is not given gets the type logic if it is the first
// argument or if its direction is given explicitly; otherwise it takes the
// type of the argument before it.
//
// The task t(a, int b, c, input d, output [3:0] e, f) and the function
// fn(a, int b, c, input d, input [3:0] e, f) have these formals:
//   a  first, no type          -> logic (1 bit, keeps x)
//   c  no type, no direction   -> int, from b (32 bits, keeps -5)
//   d  input, no type          -> logic (1 bit, keeps z), not int
//   e  output/input [3:0]      -> logic [3:0] (keeps x and z)
//   f  no type, no direction   -> logic [3:0], from e
// $bits shows the sizes; the values show the 4-state types, the sign of c
// and that a and d keep only the lowest bit of a 2-bit actual.

module test_formal_type_default_and_inheritance;
  logic [7:0] e_out, f_out;
  int r;

  task automatic t(a, int b, c, input d, output [3:0] e, f);
    $display("task bits: a=%0d b=%0d c=%0d d=%0d e=%0d f=%0d",
             $bits(a), $bits(b), $bits(c), $bits(d), $bits(e), $bits(f));
    $display("task values: a=%b c=%0d d=%b", a, c, d);
    e = 4'b10xz;
    f = 4'b0110;
  endtask

  function automatic int fn(a, int b, c, input d, input [3:0] e, f);
    $display("function bits: a=%0d b=%0d c=%0d d=%0d e=%0d f=%0d",
             $bits(a), $bits(b), $bits(c), $bits(d), $bits(e), $bits(f));
    $display("function values: a=%b c=%0d d=%b e=%b f=%b", a, c, d, e, f);
    return c + f;
  endfunction

  initial begin
    t(1'bx, 7, -5, 1'bz, e_out, f_out);
    $display("task outputs: e_out=%b f_out=%b", e_out, f_out);
    t(2'b10, 7, 3, 2'b11, e_out, f_out);
    r = fn(1'bx, 7, -5, 1'bz, 4'b01xz, 4'd9);
    $display("function result: %0d", r);
    r = fn(2'b10, 7, 3, 2'b11, 4'd0, 4'd1);
    $display("function result: %0d", r);
  end
endmodule
