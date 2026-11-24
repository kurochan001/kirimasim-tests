/*
:name: test_local_method_receiver_beats_derived_same_name_array
:description: A method uses its local class receiver despite a derived array name (IEEE 1800-2023 Section 8.6)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 6.21
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_method_receiver_beats_derived_same_name_array.expected
:expected_exit: 0
*/
// The class handle declared by the inherited method supplies its size()
// receiver. The derived fixed array has the same name.

package receivers;
  class container #(type T = int);
    function int size();
      return 7;
    endfunction
  endclass

  class parent;
    function int read_size();
      container#(string) names = new;
      return names.size();
    endfunction
  endclass
endpackage

module test_local_method_receiver_beats_derived_same_name_array;
  import receivers::*;
  class child extends parent;
    string names[2] = '{"alpha", "beta"};
  endclass

  initial begin
    automatic child c = new;
    int local_size;
    local_size = c.read_size();
    $display("CHECK local_size=%0d array_size=%0d", local_size, $size(c.names));
    if (local_size != 7)
      $fatal(1, "size() did not use the local class handle");
    if ($size(c.names) != 2 || c.names[1] != "beta")
      $fatal(1, "derived array property was modified");
    $display("CHECK pass");
    $finish;
  end
endmodule
