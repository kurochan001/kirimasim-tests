/*
:name: test_tagged_union_dynamic_and_chandle_members
:description: an unpacked tagged union can have members of dynamic types (string, queue, dynamic and associative arrays, class handle) and of type chandle, which hold their values (IEEE 1800-2023 Section 7.3.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_dynamic_and_chandle_members.expected
*/
// IEEE 1800-2023 §7.3.2: dynamic types and chandle types shall not be used in
// untagged unions, but may be used in tagged unions. dyn_t has a member of
// each kind. Each one is set with a tagged union expression (§11.9), read back
// through the member of the current tag, and the dynamic members are then
// changed in place, so the union holds the whole dynamic value and not a fixed
// copy of some bits of it.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports tagged unions.

module test_tagged_union_dynamic_and_chandle_members;
  class item_c;
    int v;
    function new(int v);
      this.v = v;
    endfunction
  endclass

  typedef union tagged {
    string S;
    int Q[$];
    int D[];
    int A[string];
    item_c H;
    chandle P;
  } dyn_t;

  dyn_t d;
  int src[];
  item_c obj;

  initial begin
    d = tagged S "abc";
    d.S = {d.S, "de"};
    $display("S: %s len=%0d", d.S, d.S.len());

    d = tagged Q '{1, 2, 3};
    d.Q.push_back(4);
    $display("Q: size=%0d first=%0d last=%0d", d.Q.size(), d.Q[0], d.Q[$]);

    src = new[3];
    src[2] = 9;
    d = tagged D src;
    src[2] = 1;
    $display("D: size=%0d D[2]=%0d", d.D.size(), d.D[2]);

    d = tagged A '{"k": 5};
    d.A["m"] = 6;
    $display("A: num=%0d k=%0d m=%0d", d.A.num(), d.A["k"], d.A["m"]);

    obj = new(7);
    d = tagged H obj;
    obj.v = 8;
    $display("H: v=%0d same object=%0d", d.H.v, d.H == obj);

    d = tagged P null;
    $display("P: is null=%0d", d.P == null);
  end
endmodule
