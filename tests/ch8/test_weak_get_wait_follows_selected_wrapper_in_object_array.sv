/*
:name: test_weak_get_wait_follows_selected_wrapper_in_object_array
:description: Waits for a weak reference in an object array respond to the selected index and to clearing that wrapper
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.3 8.30.4 9.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_get_wait_follows_selected_wrapper_in_object_array.expected
*/
`timescale 1ns/1ns
module test_weak_get_wait_follows_selected_wrapper_in_object_array;
  class payload;
  endclass
  typedef std::weak_reference #(payload) weak_payload;
  class cache;
    weak_payload items[2];
  endclass
  payload strongly_held;
  cache refs;
  int selected = 0;
  int selected_wake = 0, fixed_wake = 0;

  initial begin
    strongly_held = new;
    refs = new;
    refs.items[0] = new(strongly_held);
    refs.items[1] = new(strongly_held);
    fork
      begin
        wait (refs.items[selected].get() == null);
        selected_wake = int'($time);
      end
      begin
        wait (refs.items[0].get() == null);
        fixed_wake = int'($time);
      end
    join_none

    #2 refs.items[1].clear();
    #1 $display("unselected cleared=%0b wake=%0d/%0d",
                refs.items[1].get() == null, selected_wake, fixed_wake);
    #1 selected = 1;
    #1 $display("selection changed wake=%0d/%0d", selected_wake, fixed_wake);
    #1 refs.items[0].clear();
    #1 $display("both cleared wake=%0d/%0d strong=%0b", selected_wake, fixed_wake,
                strongly_held != null);
    $finish(0);
  end
endmodule
