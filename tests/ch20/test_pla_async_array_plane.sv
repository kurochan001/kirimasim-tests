/*
:name: test_pla_async_array_plane
:description: $async$and$array evaluates a logic array whose personality bits select inputs for each output, and $async$or$plane one whose bits take an input true, complemented or not at all; both update their outputs whenever an input or the personality changes (IEEE 1800-2023 Section 20.16)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16 20.16.1 20.16.2 20.16.3 20.16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pla_async_array_plane.expected
*/
// IEEE 1800-2023 §20.16.3: a personality memory has one word per output term
// and one bit per input term, all in ascending order. §20.16.4: in the array
// format a 1 takes the input and a 0 leaves it out, so for the and array b1 =
// a1 & a2, b2 = a2 & a3 & a4 and b3 = a4. In the plane format a 1 takes the
// input, a 0 its complement and z nothing, so for the or plane c1 = p1 | ~p3
// and c2 = p3. §20.16.1: the asynchronous forms evaluate again whenever an
// input term or the personality changes, and update the outputs without delay.
// The tasks are called before the personalities are written, so writing them
// evaluates both arrays; later, changing mem[3] makes b3 = a1.

`timescale 1ns/1ns

module test_pla_async_array_plane;
  logic [1:4] mem [1:3];
  logic [1:3] pmem [1:2];
  logic a1 = 0, a2 = 0, a3 = 0, a4 = 0;
  logic b1, b2, b3;
  logic [1:3] p = 3'b000;
  logic [1:2] c;

  initial begin
    $async$and$array(mem, {a1, a2, a3, a4}, {b1, b2, b3});
    $async$or$plane(pmem, p, c);
    mem[1] = 4'b1100;
    mem[2] = 4'b0111;
    mem[3] = 4'b0001;
    pmem[1] = 3'b1z0;
    pmem[2] = 3'bzz1;
    #1 $display("a = %b%b%b%b: b = %b%b%b", a1, a2, a3, a4, b1, b2, b3);
    {a1, a2, a3, a4} = 4'b1100;
    #1 $display("a = %b%b%b%b: b = %b%b%b", a1, a2, a3, a4, b1, b2, b3);
    {a1, a2, a3, a4} = 4'b0111;
    #1 $display("a = %b%b%b%b: b = %b%b%b", a1, a2, a3, a4, b1, b2, b3);
    mem[3] = 4'b1000;
    #1 $display("new mem[3]: b = %b%b%b", b1, b2, b3);
    $display("p = %b: c = %b", p, c);
    p = 3'b001;
    #1 $display("p = %b: c = %b", p, c);
    p = 3'b101;
    #1 $display("p = %b: c = %b", p, c);
  end
endmodule
