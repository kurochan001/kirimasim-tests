/*
:name: test_port_collapse_uwire_external_delay
:description: A wire or tri port connected to an outer uwire net merges into the external uwire net, whose delay the simulated net takes, with the single driver the uwire allows (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.1 6.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_collapse_uwire_external_delay.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets, the simulated net
// takes the net type that Table 23-1 selects and "the delay specified for
// the dominating net". The wire/tri row of the table selects the external
// net when the internal net is a wire or tri and the external net is a
// uwire, without a warning. A uwire net is an unresolved net that allows
// only a single driver (§6.6.2), and both wire and uwire pass the value of
// that driver, so the resolved value cannot show which of the two
// declarations the table selected; the net delay each declaration
// specifies (§28.16) can. Each cell has the one driver inside the module,
// so the design stays legal whichever net is chosen. The internal
// declaration has delay 3 and the external uwire has delay 7. Choosing the
// external uwire, as the table says, gives the merged net delay 7;
// keeping the internal net would give delay 3, adding the two delays would
// give 10 and no delay 0.
// The driver d goes to 1 at time 10 and to 0 at time 30, and each cell is
// sampled 2, 5 and 9 time units after each change. Delay 7 reads
// 0, 0, 1, 1, 1, 0 (001110); delay 3 would read 011100, delay 10 000111
// and no delay 111000. Icarus Verilog 13.0 does not support net delays, so
// this expected output follows the standard alone.

module pcuw_in_wire(w, d);
  parameter int D = 3;
  inout w;
  input d;
  wire #(D) w;
  assign w = d;
endmodule

module pcuw_in_tri(w, d);
  parameter int D = 3;
  inout w;
  input d;
  tri #(D) w;
  assign w = d;
endmodule

module test_port_collapse_uwire_external_delay;
  logic d;

  uwire #7 n_wire, n_tri;
  pcuw_in_wire #(.D(3)) u_wire(n_wire, d);
  pcuw_in_tri #(.D(3)) u_tri(n_tri, d);

  logic [0:5] s_wire, s_tri;

  task automatic sample(int k);
    s_wire[k] = n_wire;
    s_tri[k] = n_tri;
  endtask

  initial begin
    d = 1'b0;
    #10 d = 1'b1;
    #2 sample(0);
    #3 sample(1);
    #4 sample(2);
    #11 d = 1'b0;
    #2 sample(3);
    #3 sample(4);
    #4 sample(5);
    $display("wire inside, uwire outside: %b", s_wire);
    $display("tri inside, uwire outside:  %b", s_tri);
  end
endmodule
