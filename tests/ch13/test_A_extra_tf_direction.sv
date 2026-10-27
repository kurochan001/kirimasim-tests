/*
:name: test_A_extra_tf_direction
:description: A tf port direction is a port direction or the optional const, ref and static qualifiers, so a const ref port reads its actual and a ref port writes it while other ports keep their values (IEEE 1800-2023 Sections 13.3 and 13.5.2, A.2.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.5.2 A.2.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_tf_direction.expected
*/
// IEEE 1800-2023 A.2.7, tf_port_direction: a tf port direction is a
// port_direction (input, output, inout or ref) or the optional const, then
// ref, then the optional static. The const ref port reads its actual but may
// not write it; the ref port writes its actual when the task returns, so b
// becomes 4 while a keeps 1.

module test_A_extra_tf_direction;
  int a = 1;
  int b = 0;

  task automatic add(const ref int x, ref int y);
    y = x + 2;
  endtask

  task automatic bump(ref int y);
    y = y + 1;
  endtask

  initial begin
    add(a, b);
    bump(b);
    $display("%0d %0d", a, b);
  end
endmodule
