/*
:name: test_assoc_allocate_on_write
:description: A nonexistent associative array element is allocated when it is assigned or passed by reference, and an increment or member write first allocates it with its default or initial value (IEEE 1800-2023 Section 7.8.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.7 7.9.11 7.9.1 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_allocate_on_write.expected
*/
// IEEE 1800-2023 §7.8.7: a nonexistent element of an associative array is
// allocated when it is the target of an assignment or an actual argument
// passed by reference. An operation that reads and writes it, such as +=,
// first allocates it with its default value, here the default:10 of hits, so
// "x" ends at 15. Writing one member of a nonexistent struct element allocates
// the element with the member initializers of its type, so pts[7] keeps lo = 3
// beside the hi written. set_to, with a ref argument, allocates "new". A read
// of a nonexistent element gives the default and allocates nothing (7.9.11).

module test_assoc_allocate_on_write;
  typedef struct {
    int lo = 3;
    int hi = 9;
  } range_t;

  int hits[string] = '{default: 10};
  range_t pts[int];
  int seen;

  task automatic set_to(ref int r, input int v);
    r = v;
  endtask

  initial begin
    hits["x"] += 5;
    pts[7].hi = 1;
    set_to(hits["new"], 42);
    seen = hits["absent"];
    $display("x=%0d new=%0d absent read as %0d", hits["x"], hits["new"], seen);
    $display("hits has %0d entries, absent exists: %0d", hits.num(), hits.exists("absent"));
    $display("pts[7]: lo=%0d hi=%0d, entries=%0d", pts[7].lo, pts[7].hi, pts.num());
  end
endmodule
