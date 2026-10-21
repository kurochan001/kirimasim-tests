/*
:name: test_cg_sample_args_guard_shadow
:description: The arguments of an overridden sample method hide module variables of the same name, in the coverpoint and in its iff guard, and can be passed from local variables of an automatic function (IEEE 1800-2023 Section 19.8.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8.1 19.5 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_sample_args_guard_shadow.expected
*/
// IEEE 1800-2023 §19.8.1: the formal arguments of an overridden sample method
// are searched before the enclosing scope, and can designate a coverpoint or
// its iff guard (19.5). So x and en in the covergroup are the arguments, not
// the module variables x and en, which hold 2 and 1 throughout. The function
// put passes a local variable of an automatic function as x. A call with en 0
// covers nothing, although the module variables would cover b[2]. The
// coverpoint has 4 bins (19.11.1).

module test_cg_sample_args_guard_shadow;
  bit [1:0] x = 2;
  bit en = 1;

  covergroup cg with function sample (bit [1:0] x, bit en);
    cx: coverpoint x iff (en) { bins b[] = {[0:3]}; }
  endgroup

  cg inst = new();

  function automatic void put(int k, bit e);
    bit [1:0] val;
    val = k;
    inst.sample(val, e);
    $display("after sample(%0d, %0d): %.2f", k, e, inst.get_inst_coverage());
  endfunction

  initial begin
    put(1, 1);
    put(2, 0);
    put(0, 1);
  end
endmodule
