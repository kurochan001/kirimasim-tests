/*
:name: test_cg_embedded_in_class
:description: A covergroup declared in a class covers the properties of its object, and each object has its own coverage (IEEE 1800-2023 Section 19.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_embedded_in_class.expected
*/
// IEEE 1800-2023 §19.4: a covergroup declared inside a class is an embedded
// covergroup. Its coverpoints can use the properties of the class, it is created
// with new in the constructor, and the instance of each object counts only the
// samples taken through that object.

class cg_owner;
  bit [1:0] v;

  covergroup cg;
    cp: coverpoint v { bins b[] = {[0:3]}; }
  endgroup

  function new();
    cg = new;
  endfunction

  function void put(bit [1:0] x);
    v = x;
    cg.sample();
  endfunction
endclass

module test_cg_embedded_in_class;
  cg_owner o1, o2;

  initial begin
    o1 = new;
    o2 = new;
    o1.put(0);
    o1.put(1);
    o2.put(3);
    $display("o1: %0.2f o2: %0.2f", o1.cg.get_inst_coverage(), o2.cg.get_inst_coverage());
  end
endmodule
