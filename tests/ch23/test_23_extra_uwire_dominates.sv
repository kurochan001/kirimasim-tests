/*
:name: test_23_extra_uwire_dominates
:description: With an internal uwire, Table 23-1 selects the internal uwire for an external wire and the external uwire for an external uwire, as the delay of the merged net shows (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.2 6.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_uwire_dominates.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the simulated net takes the net type that Table 23-1 selects and
// the delay specified for that net. For an internal uwire the table selects
// the internal uwire when the external net is a wire or tri, and the
// external net when the external net is also a uwire. A uwire allows one
// driver only (§6.6.2), so each cell has its single driver inside the
// module and none outside.
// Both cells have an internal uwire with delay 3. The external wire and the
// external uwire have delay 7. Choosing the internal uwire, as the table
// says for the wire, gives the merged net delay 3; choosing the external
// uwire, as the table says for the uwire, gives delay 7. Keeping the other
// net would give the other delay, and adding the two would give 10.
// The driver d goes to 1 at time 10 and to 0 at time 30, and each cell is
// sampled 2, 5 and 9 time units after each change. Delay 3 reads
// 0, 1, 1, 1, 0, 0 (011100); delay 7 reads 0, 0, 1, 1, 1, 0 (001110).
// Icarus Verilog 13.0 does not support net delays and Verilator 5.052
// rejects these uwire inout connections, so this expected output follows the
// standard alone; see the note below.

module ud_in_uwire(w, d);
  parameter int D = 3;
  inout w;
  input d;
  uwire #(D) w;
  assign w = d;
endmodule

module test_23_extra_uwire_dominates;
  logic d;
  wire #7 n_wire;
  uwire #7 n_uwire;
  ud_in_uwire #(.D(3)) u_wire(n_wire, d);
  ud_in_uwire #(.D(3)) u_uwire(n_uwire, d);
  logic [0:5] s_wire, s_uwire;

  task automatic sample(int k);
    s_wire[k] = n_wire;
    s_uwire[k] = n_uwire;
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
    $display("uwire inside, wire outside:  %b", s_wire);
    $display("uwire inside, uwire outside: %b", s_uwire);
  end
endmodule
