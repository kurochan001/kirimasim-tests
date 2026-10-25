/*
:name: test_edge_table_all_scalar_transitions
:description: every one of the 16 scalar transitions between 0, 1, x and z wakes posedge, negedge and edge event controls exactly as Table 9-2 says (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_edge_table_all_scalar_transitions.expected
*/
// IEEE 1800-2023 §9.4.2 and Table 9-2: a posedge is a change from 0 to 1, x
// or z, or from x or z to 1; a negedge is a change from 1 to 0, x or z, or
// from x or z to 0. Changes between x and z, and writes of the value a
// variable already has, are no edge. An edge event happens whenever a
// posedge or a negedge happens.
//
// The test puts a 4-state scalar into each of the four values, waits one
// time unit so that the event controls are armed again, then writes each of
// the four values, and prints how many times a posedge, a negedge and an
// edge event control woke for that second write. All 16 pairs of the table
// are tried, including the four that write the same value again.

module test_edge_table_all_scalar_transitions;
  logic s;
  int pos = 0, neg = 0, any = 0;

  always @(posedge s) pos++;
  always @(negedge s) neg++;
  always @(edge s) any++;

  function automatic logic val(int k);
    case (k)
      0: return 1'b0;
      1: return 1'b1;
      2: return 1'bx;
      default: return 1'bz;
    endcase
  endfunction

  initial begin
    int p0, n0, a0;
    #1;
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++) begin
        s = val(i);
        #1;
        p0 = pos; n0 = neg; a0 = any;
        s = val(j);
        #1;
        $display("%b->%b posedge=%0d negedge=%0d edge=%0d",
                 val(i), val(j), pos - p0, neg - n0, any - a0);
      end
  end
endmodule
