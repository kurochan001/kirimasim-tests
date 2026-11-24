/*
:name: test_virtual_prototype_protected_and_const_reference
:description: An override keeps the protected virtual prototype with a constant reference formal
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 13.5.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_prototype_protected_and_const_reference.expected
*/
module test_virtual_prototype_protected_and_const_reference;
  class base_t;
    protected virtual function bit [7:0] transform(const ref bit [7:0] data);
      return data + 8'd1;
    endfunction

    function bit [7:0] run(const ref bit [7:0] data);
      return transform(data);
    endfunction
  endclass

  class derived_t extends base_t;
    protected function bit [7:0] transform(const ref bit [7:0] data);
      return data ^ 8'hff;
    endfunction
  endclass

  base_t normal, polymorphic;
  derived_t custom;
  bit [7:0] data;

  initial begin
    normal = new;
    custom = new;
    polymorphic = custom;
    data = 8'h3c;
    $display("base=%h override=%h original=%h", normal.run(data), polymorphic.run(data), data);
  end
endmodule
