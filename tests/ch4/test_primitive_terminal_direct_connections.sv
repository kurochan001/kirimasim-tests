/*
:name: test_primitive_terminal_direct_connections
:description: Primitive terminals connect directly to 1-bit nets and net bit-selects, keeping the strength of the net, while an input given by another expression goes through an implicit continuous assignment, and primitive output changes are Active update events (IEEE 1800-2023 Section 4.9.6)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.6 28.7 28.13 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_primitive_terminal_direct_connections.expected
*/
// IEEE 1800-2023 §4.9.6: primitive output terminals connect directly to
// 1-bit nets or 1-bit structural net expressions, with nothing in between
// that could change the strength, and input terminals connected to them are
// direct too; an input terminal given by another expression is an implicit
// continuous assignment, of strong strength, to an implicit net. Changes from
// primitive evaluations are Active update events of the connected nets.
// §28.7 and §28.13: an nmos switch passes the strength of its data input.
// wp and the bit wv[1] are driven with pull strength. The nmos switches n1
// and n3 take them directly and pass Pu to their outputs; n2 takes the
// expression wp & 1'b1, which becomes a strong implicit net, so its output
// is St. The bufif1 g1 has weak strengths and drives o4 directly. The buf
// g2 has pull strengths and drives the bit ov[0] directly, against a pull
// driver of the opposite value: two pull drivers give x, where a strong
// output would win. At time 1 d goes from 1 to 0, and after #0, in the
// Inactive region, all the primitives have already been evaluated and their
// outputs updated.
// Icarus Verilog 13.0 gives o3=St1: it does not keep the pull strength of
// the bit wv[1] at the input of n3. The release 5.052 of Verilator does not
// model strengths.

module test_primitive_terminal_direct_connections;
  logic d = 1'b1;
  wire wp, o1, o2, o3, o4;
  wire [1:0] wv, ov;

  assign (pull1, pull0) wp = d;
  assign (pull1, pull0) wv = {d, 1'b0};

  nmos n1(o1, wp, 1'b1);
  nmos n2(o2, wp & 1'b1, 1'b1);
  nmos n3(o3, wv[1], 1'b1);
  bufif1 (weak1, weak0) g1(o4, d, 1'b1);
  buf (pull1, pull0) g2(ov[0], d);
  assign (pull1, pull0) ov[0] = ~d;

  initial begin
    #1 $display("d=1: o1=%v o2=%v o3=%v o4=%v ov0=%b", o1, o2, o3, o4, ov[0]);
    d = 1'b0;
    #0 $display("d=0: o1=%v o2=%v o3=%v o4=%v ov0=%b", o1, o2, o3, o4, ov[0]);
  end
endmodule
