/*
:name: test_interface_class_null_handle_cast
:description: $cast from an interface class handle that holds null succeeds and assigns null only when the destination type is assignment compatible with the static type of the source; when the cast would need the run-time check of an object it fails and leaves the destination unchanged (IEEE 1800-2023 Sections 8.26.5 and 8.16)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.5 8.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_null_handle_cast.expected
*/
// IEEE 1800-2023 §8.26.5: a cast from an interface class handle that is null
// follows the rules for a class handle that is null (8.16). §8.16: $cast on
// class handles succeeds only when (1) the destination type is the source
// type or a supertype of it, (2) the source type is a superclass of the
// destination type or an interface class and the source is an object that
// can be assigned to the destination, or (3) the source is the literal
// null; it fails in all other cases, also when the source evaluates to null.
// A failing $cast called as a function returns 0 and does not assign
// (6.24.2).
//
// ext_if extends base_if, and item_c implements ext_if. A null ext_if handle
// cast to ext_if or to base_if is case (1): it succeeds and the destination
// becomes null. A null base_if handle cast to ext_if or to item_c could only
// succeed as case (2), which needs an object, so it fails and the
// destination keeps the item it held. With an object in the base_if handle
// the same casts succeed, and the literal null always succeeds.
//
// The 5.052 release of Verilator lets both casts of the null base_if handle
// succeed and assign null; Icarus Verilog 13.0 does not support interface
// classes.

module test_interface_class_null_handle_cast;
  interface class base_if;
    pure virtual function int id();
  endclass

  interface class ext_if extends base_if;
    pure virtual function int twice();
  endclass

  class item_c implements ext_if;
    int n;
    function new(int n);
      this.n = n;
    endfunction
    virtual function int id();
      return n;
    endfunction
    virtual function int twice();
      return 2 * n;
    endfunction
  endclass

  item_c keep, other, ic;
  base_if b, bn;
  ext_if e, en;
  int ok;

  initial begin
    keep = new(7);
    en = null;
    bn = null;

    e = keep;
    ok = $cast(e, en);
    $display("null ext_if to ext_if: ok=%0d dest null=%0d", ok, e == null);
    b = keep;
    ok = $cast(b, en);
    $display("null ext_if to base_if: ok=%0d dest null=%0d", ok, b == null);

    e = keep;
    ok = $cast(e, bn);
    $display("null base_if to ext_if: ok=%0d dest kept=%0d", ok, e == keep);
    ic = keep;
    ok = $cast(ic, bn);
    $display("null base_if to item_c: ok=%0d dest kept=%0d", ok, ic == keep);

    other = new(5);
    b = other;
    e = keep;
    ok = $cast(e, b);
    $display("base_if with an object to ext_if: ok=%0d twice=%0d", ok, e.twice());
    ic = keep;
    ok = $cast(ic, b);
    $display("base_if with an object to item_c: ok=%0d id=%0d", ok, ic.id());

    e = keep;
    ok = $cast(e, null);
    $display("literal null to ext_if: ok=%0d dest null=%0d", ok, e == null);
  end
endmodule
