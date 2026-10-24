/*
:name: test_queue_invalid_index_read_defaults
:description: reading a queue with an index below 0, above $, or with an x or z bit returns the nonexistent-entry value of its element type: 0 for int, x for logic, the empty string for string (IEEE 1800-2023 Section 7.10.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.1 7.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_queue_invalid_index_read_defaults.expected
*/
// IEEE 1800-2023 §7.10.1: an index of a queue is invalid when it is a 4-state
// value with x or z bits or lies outside 0 to $, and a read with it returns the
// value for a nonexistent entry of the element type, from Table 7-1 (§7.4.5):
// '0 for a 2-state type, 'x for a 4-state type and "" for string.
// Each queue holds values that differ from those defaults. The index $+1
// (equal to the size) is valid only for a write, so a read with it is invalid
// as well. The queues are read with -1, with their size, with an index far
// above $ and with an index with an x bit or a z bit.

module test_queue_invalid_index_read_defaults;
  int qi[$] = '{5, 6, 7};
  logic [3:0] ql[$] = '{4'h1, 4'h2};
  string qs[$] = '{"a", "b"};
  int neg = -1;
  int far = 100;
  logic [1:0] xi = 2'bx0;
  logic [1:0] zi = 2'b0z;

  initial begin
    $display("valid: qi[2]=%0d ql[1]=%h qs[1]=%s", qi[2], ql[1], qs[1]);
    $display("int: [-1]=%0d [size]=%0d [100]=%0d [x]=%0d [z]=%0d", qi[neg], qi[qi.size()],
             qi[far], qi[xi], qi[zi]);
    $display("logic: [-1]=%h [size]=%h [100]=%h [x]=%h [z]=%h", ql[neg], ql[ql.size()],
             ql[far], ql[xi], ql[zi]);
    $display("string: [-1]=\"%s\" [size]=\"%s\" [x]=\"%s\"", qs[neg], qs[qs.size()], qs[xi]);
    $display("sizes unchanged: %0d %0d %0d", qi.size(), ql.size(), qs.size());
  end
endmodule
