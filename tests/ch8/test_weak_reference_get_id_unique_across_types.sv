/*
:name: test_weak_reference_get_id_unique_across_types
:description: The get_id() value of an object differs from the value of every other object that exists at the same time, whatever their classes, weak_reference objects included, and stays the same while many other objects are created and dropped (IEEE 1800-2023 Section 8.30.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_get_id_unique_across_types.expected
*/
// IEEE 1800-2023 §8.30.5: the identification value that get_id() returns for
// an object is unique among all objects, whatever their types, for as long as
// the object exists; only after the object has been garbage collected may its
// value be given to another object.
//
// Four objects are kept for the whole run: one of the class red, one of the
// unrelated class blue, one of dark_red, which extends red, and a
// weak_reference that refers to the red object, whose value comes from get_id()
// of weak_reference #(red_ref). A tool that numbered the objects of each class,
// or the calls of each specialization of weak_reference, apart would give some
// of them equal values. Then, in three rounds at times 1, 2 and 3, the test
// creates 50 new objects of each of these four kinds and holds all of them in
// queues while it enters the values of the four kept objects and of the 200 new
// ones in an associative array (7.8), counting each value that is already
// there. The new objects are dropped when the round ends, so a later round may
// get their values again, which the standard allows, and each round counts on
// its own. The kept objects are never dropped, so their values do not repeat in
// any round and are the same at the end as at the start. The values themselves
// are not printed, only how they compare.

`timescale 1ns/1ns

module test_weak_reference_get_id_unique_across_types;
  class red;
  endclass

  class blue;
  endclass

  class dark_red extends red;
  endclass

  typedef weak_reference #(red) red_ref;
  typedef weak_reference #(blue) blue_ref;
  typedef weak_reference #(dark_red) dark_red_ref;
  typedef weak_reference #(red_ref) ref_ref;

  red kept_red;
  blue kept_blue;
  dark_red kept_dark;
  red_ref kept_ref;
  longint kept[4];
  longint again[4];
  bit seen[longint];
  int repeated;
  int nonzero;
  int equal_pairs;

  function automatic void kept_values(output longint v[4]);
    v[0] = red_ref::get_id(kept_red);
    v[1] = blue_ref::get_id(kept_blue);
    v[2] = dark_red_ref::get_id(kept_dark);
    v[3] = ref_ref::get_id(kept_ref);
  endfunction

  function automatic void enter(longint v);
    if (seen.exists(v)) repeated++;
    else seen[v] = 1;
  endfunction

  task automatic round(int n);
    red reds[$];
    blue blues[$];
    dark_red darks[$];
    red_ref refs[$];
    red r;
    blue b;
    dark_red d;
    red_ref w;
    for (int i = 0; i < 50; i++) begin
      r = new();
      b = new();
      d = new();
      w = new(kept_red);
      reds.push_back(r);
      blues.push_back(b);
      darks.push_back(d);
      refs.push_back(w);
    end
    seen.delete();
    repeated = 0;
    foreach (kept[k]) enter(kept[k]);
    foreach (reds[i]) enter(red_ref::get_id(reds[i]));
    foreach (blues[i]) enter(blue_ref::get_id(blues[i]));
    foreach (darks[i]) enter(dark_red_ref::get_id(darks[i]));
    foreach (refs[i]) enter(ref_ref::get_id(refs[i]));
    $display("round %0d: %0d different values, %0d repeated", n, seen.num(), repeated);
  endtask

  initial begin
    kept_red = new();
    kept_blue = new();
    kept_dark = new();
    kept_ref = new(kept_red);
    kept_values(kept);
    nonzero = 0;
    equal_pairs = 0;
    foreach (kept[i]) begin
      if (kept[i] != 0) nonzero++;
      foreach (kept[j])
        if (i < j && kept[i] == kept[j]) equal_pairs++;
    end
    $display("kept objects: %0d nonzero values, %0d equal pairs", nonzero, equal_pairs);
    for (int n = 1; n <= 3; n++) begin
      #1;
      round(n);
    end
    kept_values(again);
    $display("kept objects at time %0d: values unchanged %0d", $time, again == kept);
  end
endmodule
