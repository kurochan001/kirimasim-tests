/*
:name: test_udp_instance_array_delays
:description: An array of UDP instances connects one bit of a vector to each instance and a scalar to all of them, and its rise and fall delays apply per instance, with the smaller one for a change to x (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 28.3.6 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_instance_array_delays.expected
*/
// IEEE 1800-2023 §29.8, §28.3.6: u[3:0] is four instances; the 4-bit a and y
// give each instance one bit, u[0] the least significant one, and the 1-bit b
// goes to all four. A UDP instance takes at most two delays (28.16): 2 for a
// change to 1 and 5 for a change to 0; a change to x takes the smaller, 2.
// The inputs become known at 0, so y is x until the fall delay has passed.
// The test samples y between the scheduled changes.

primitive udp_xor2 (y, a, b);
  output y;
  input a, b;
  table
  // a b : y
     0 0 : 0;
     0 1 : 1;
     1 0 : 1;
     1 1 : 0;
  endtable
endprimitive

module test_udp_instance_array_delays;
  reg [3:0] a;
  reg b;
  wire [3:0] y;

  udp_xor2 #(2, 5) u[3:0] (y, a, b);

  initial begin
    a = 4'b0000;
    b = 0;
    #4 $display("t=%0d: y=%b", $time, y);
    #2 $display("t=%0d: y=%b", $time, y);
    #4 a = 4'b0101;        // 10: y[2] and y[0] rise at 12
    #1 $display("t=%0d: y=%b", $time, y);
    #2 $display("t=%0d: y=%b", $time, y);
    #7 b = 1;              // 20: y[3] and y[1] rise at 22, y[2] and y[0] fall at 25
    #3 $display("t=%0d: y=%b", $time, y);
    #3 $display("t=%0d: y=%b", $time, y);
    #4 a[1] = 1'bx;        // 30: y[1] goes to x at 32
    #1 $display("t=%0d: y=%b", $time, y);
    #2 $display("t=%0d: y=%b", $time, y);
  end
endmodule
