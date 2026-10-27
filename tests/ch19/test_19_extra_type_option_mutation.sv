/*
:name: test_19_extra_type_option_mutation
:description: Weight, goal and comment of type_option can be assigned during simulation, while strobe is accepted only in the covergroup definition (IEEE 1800-2023 Section 19.7.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7.1 19.10 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_extra_type_option_mutation.expected
*/
// IEEE 1800-2023 §19.7.1: type_option.strobe and type_option.real_interval may
// be set only in the covergroup definition; the other type options may be
// assigned procedurally during simulation. The covergroup sets strobe in its
// definition, which is accepted, and the initial block then assigns weight,
// goal and comment and reads them back through the instance. Sampling still
// works after the assignments. The definition-only rule is only tested in the
// accepting direction: Verilator 5.052 accepts a procedural assignment to
// strobe as well, and a procedural assignment to real_interval stops in its
// generated C++ code.

module test_19_extra_type_option_mutation;
  bit [1:0] a;

  covergroup cg;
    type_option.strobe = 1;
    cp: coverpoint a { bins v[] = {[0:1]}; }
  endgroup

  cg g;

  initial begin
    g = new;
    g.type_option.weight = 5;
    g.type_option.goal = 70;
    g.type_option.comment = "set during simulation";
    $display("weight %0d, goal %0d, comment [%s]", g.type_option.weight,
             g.type_option.goal, g.type_option.comment);
    a = 0;
    g.sample();
    $display("after sample 0, below 100: %0d", g.get_inst_coverage() < 100.0);
    a = 1;
    g.sample();
    $display("after sample 1: %0.2f", g.get_inst_coverage());
  end
endmodule
