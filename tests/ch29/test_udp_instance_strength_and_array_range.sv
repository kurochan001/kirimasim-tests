/*
:name: test_udp_instance_strength_and_array_range
:description: UDP instances can have a drive strength, which sets the strength of the 0 and the 1 they drive, and a range that makes an array of instances, which connects a vector one bit per instance and a scalar to all instances (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 29.3.2 28.3.6 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_instance_strength_and_array_range.expected
*/
// IEEE 1800-2023 §29.8: a UDP instance can have a drive strength after the
// UDP name, and an instance name can have a range, which makes an array of
// instances whose terminals are connected as for gates (28.3.6, which
// §29.3.2 applies to UDP terminals): a vector with one bit per instance
// gives each instance one bit, and a scalar goes to every instance. The
// unnamed u_buf instance has (pull0, weak1), so %v (21.2.1.4) shows its 0 as
// Pu0 and its 1 as We1, and g_s has (supply1, strong0). The array g_arr[0:3]
// of u_and2 instances ands each bit of v4 with the scalar s.
// Icarus Verilog 13.0 and Verilator 5.052 reject a drive strength on a UDP
// instance (syntax errors), and Icarus Verilog does not support arrays of
// UDP instances.

primitive u_buf(y, a);
  output y;
  input a;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

primitive u_and2(y, a, b);
  output y;
  input a, b;
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive

module test_udp_instance_strength_and_array_range;
  logic a, s;
  logic [3:0] v4;
  wire o_p, o_s;
  wire [3:0] y4;

  u_buf (pull0, weak1) (o_p, a);
  u_buf (supply1, strong0) g_s(o_s, a);
  u_and2 g_arr[0:3] (y4, v4, s);

  initial begin
    a = 1'b0; s = 1'b1; v4 = 4'b0110;
    #1 $display("a=%b: (pull0, weak1)=%v (supply1, strong0)=%v", a, o_p, o_s);
    $display("v4=%b s=%b: y4=%b", v4, s, y4);
    a = 1'b1; s = 1'b0;
    #1 $display("a=%b: (pull0, weak1)=%v (supply1, strong0)=%v", a, o_p, o_s);
    $display("v4=%b s=%b: y4=%b", v4, s, y4);
    s = 1'b1; v4 = 4'b1001;
    #1 $display("v4=%b s=%b: y4=%b", v4, s, y4);
  end
endmodule
