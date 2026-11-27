/*
:name: test_weak_reference_reclamation
:description: Weak wrappers and numeric keys remain observable when the original class object becomes collectible
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.29 8.30.1 8.30.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_reclamation.expected
:files: weak_reclamation/driver.cpp weak_reclamation/reference.expected weak_reclamation/strong.expected
*/
`timescale 1ns/1ps

class weak_gc_payload;
  int serial;
  function new(int serial);
    this.serial = serial;
  endfunction
endclass

`ifdef REFERENCE_WEAK
import "DPI-C" function int make_weak_view(input int serial);
import "DPI-C" function int read_weak_view(input int view);
import "DPI-C" function longint weak_numeric_id(input int serial);

class weak_gc_view;
  int slot;
  function new(weak_gc_payload referent);
    slot = make_weak_view(referent.serial);
  endfunction
  function int read_serial();
    return read_weak_view(slot);
  endfunction
  static function longint get_id(weak_gc_payload referent);
    return weak_numeric_id(referent.serial);
  endfunction
endclass
typedef weak_gc_view view_t;
`else
typedef std::weak_reference #(weak_gc_payload) view_t;
`endif

module test_weak_reference_reclamation;
  class box;
    view_t view;
  endclass

  task automatic transfer(ref view_t destination, input view_t source);
    destination = source;
  endtask

  function automatic int read_serial(view_t view);
`ifdef REFERENCE_WEAK
    return view.read_serial();
`else
    weak_gc_payload current = view.get();
    return current == null ? -1 : current.serial;
`endif
  endfunction

  weak_gc_payload owner /* verilator public_flat_rw */;
  weak_gc_payload peer /* verilator public_flat_rw */;
  weak_gc_payload replacement /* verilator public_flat_rw */;
  view_t retired /* verilator public_flat_rw */;
  view_t moving, right, peer_view;
  box retained;
  int by_id[longint];
  longint original_id, peer_id, replacement_id;

  initial begin
    owner = new(29);
    peer = new(47);
    #1;
    retired = new(owner);
    moving = new(owner);
    right = new(owner);
    peer_view = new(peer);
    retained = new;
    transfer(retained.view, moving);
    moving = null;

    original_id = view_t::get_id(owner);
    peer_id = view_t::get_id(peer);
    by_id[original_id] = 17;
    by_id[peer_id] = 41;
    $display("live left=%0d right=%0d peer=%0d ids-distinct=%0d",
             read_serial(retained.view), read_serial(right), read_serial(peer_view),
             original_id != 0 && peer_id != 0 && original_id != peer_id);

    #1 retired = null;
    #1 $display("after wrapper drop left=%0d right=%0d",
                read_serial(retained.view), read_serial(right));
    #1 owner = null;
    #1;
`ifdef REFERENCE_WEAK
    $display("after collection left=%0d right=%0d", read_serial(retained.view), read_serial(right));
`else
    if ($test$plusargs("observe_native_weak"))
      $display("native after drop left=%0d right=%0d",
               read_serial(retained.view), read_serial(right));
`endif
    $display("after strong drop key=%0d peer=%0d peer-key=%0d",
             by_id[original_id], read_serial(peer_view), by_id[peer_id]);
    replacement = new(63);
    #1;
    replacement_id = view_t::get_id(replacement);
    $display("replacement live=%0d peer-distinct=%0d old-key=%0d",
             replacement_id != 0, replacement_id != peer_id, by_id[original_id]);
`ifdef REFERENCE_WEAK
    $display("reused=%0d old-views=%0d,%0d",
             replacement_id == original_id, read_serial(retained.view), read_serial(right));
`endif
    #1 $finish(0);
  end
endmodule
