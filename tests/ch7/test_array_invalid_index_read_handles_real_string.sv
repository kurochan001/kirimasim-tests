/*
:name: test_array_invalid_index_read_handles_real_string
:description: reading an unpacked array of real, shortreal, string, class, interface class, event or virtual interface elements with an out-of-bounds index or an index with an x bit gives 0.0, an empty string or null (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_invalid_index_read_handles_real_string.expected
*/
// IEEE 1800-2023 §7.4.5: an index that is out of bounds, or that has an x or
// z bit, is invalid, and reading an unpacked array with it returns the value
// of Table 7-1 for the element type: 0.0 for real and shortreal, "" for
// string, and null for class, interface class, event and virtual interface
// handles (for an event, null and not a new synchronization object).
// Every element of each array is first given a value that differs from that
// one, as the reads of the valid index 1 show. Each array is then read with
// the out-of-bounds index 7 and with the index 2'b1x.
// Icarus Verilog 13.0 does not support interface classes. Verilator 5.052
// cannot build the reads of the event array, and without them it returns
// stored element values (1.5, "full", non-null handles) for both indices.

interface class shape_if;
  pure virtual function int sides();
endclass

class square_c implements shape_if;
  virtual function int sides();
    return 4;
  endfunction
endclass

class obj_c;
  int v = 1;
endclass

interface bus_if;
  logic [3:0] d;
endinterface

module test_array_invalid_index_read_handles_real_string;
  bus_if bus0 ();

  real r [0:3];
  shortreal sr [0:3];
  string s [0:3];
  obj_c c [0:3];
  shape_if ic [0:3];
  event e [0:3];
  virtual bus_if vi [0:3];

  int oob = 7;
  logic [1:0] xi = 2'b1x;
  square_c sq;

  initial begin
    foreach (r[k]) begin
      r[k] = 1.5;
      sr[k] = 2.5;
      s[k] = "full";
      c[k] = new;
      sq = new;
      ic[k] = sq;
      vi[k] = bus0;
    end
    $display("valid: r=%0.1f sr=%0.1f s=%s c.v=%0d ic.sides=%0d e null=%0d vi null=%0d",
             r[1], sr[1], s[1], c[1].v, ic[1].sides(), e[1] == null, vi[1] == null);
    $display("out of bounds: r=%0.1f sr=%0.1f s=\"%s\" len=%0d", r[oob], sr[oob], s[oob],
             s[oob].len());
    $display("out of bounds null: class=%0d interface class=%0d event=%0d virtual interface=%0d",
             c[oob] == null, ic[oob] == null, e[oob] == null, vi[oob] == null);
    $display("x index: r=%0.1f sr=%0.1f s=\"%s\" len=%0d", r[xi], sr[xi], s[xi], s[xi].len());
    $display("x index null: class=%0d interface class=%0d event=%0d virtual interface=%0d",
             c[xi] == null, ic[xi] == null, e[xi] == null, vi[xi] == null);
  end
endmodule
