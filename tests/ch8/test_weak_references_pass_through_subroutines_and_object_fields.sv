/*
:name: test_weak_references_pass_through_subroutines_and_object_fields
:description: Weak-reference aliases in object fields and task arguments preserve the same wrapper independently of other wrappers
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.1 8.30.2 8.30.3 8.30.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_references_pass_through_subroutines_and_object_fields.expected
*/
`timescale 1ns/1ns
module test_weak_references_pass_through_subroutines_and_object_fields;
  class payload;
    int serial;
    function new(int serial);
      this.serial = serial;
    endfunction
  endclass
  typedef std::weak_reference #(payload) weak_payload;

  class cache;
    weak_payload items[2];
    function weak_payload get_slot(int index);
      return items[index];
    endfunction
  endclass

  task automatic transfer(ref weak_payload destination, input weak_payload source);
    #2 destination = source;
  endtask

  payload root_payload;
  weak_payload shared_wrapper, first_copy, second_copy;
  cache first, second;

  initial begin
    root_payload = new(47);
    shared_wrapper = new(root_payload);
    first = new;
    second = new;
    first.items[0] = shared_wrapper;
    first.items[1] = new(root_payload);
    transfer(second.items[0], first.get_slot(0));
    first_copy = second.get_slot(0);
    second_copy = first.get_slot(1);
    $display("t=%0d same_wrapper=%0b different=%0b objects=%0d/%0d", $time,
             first_copy == shared_wrapper, second_copy != shared_wrapper,
             first_copy.get().serial, second_copy.get().serial);
    first_copy.clear();
    $display("cleared=%0b/%0b/%0b separate=%0b strong=%0d",
             shared_wrapper.get() == null, first.items[0].get() == null,
             second.items[0].get() == null, second_copy.get() == root_payload, root_payload.serial);
    $finish(0);
  end
endmodule
