/*
:name: test_inherited_randomize_hooks_call_defining_super_once
:description: Inherited randomize hooks each invoke their defining super once (IEEE 1800-2023 Section 18.6.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.2 8.15
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inherited_randomize_hooks_call_defining_super_once.expected
:expected_exit: 0
*/
// Randomization through a base handle invokes the inherited pre and post
// hooks. Each super call runs the base implementation exactly once.

module test_inherited_randomize_hooks_call_defining_super_once;
  class base_object;
    rand bit [3:0] value;
    static int base_pre = 0;
    static int base_post = 0;
    function void pre_randomize();
      base_pre++;
    endfunction
    function void post_randomize();
      base_post++;
    endfunction
  endclass
  class hooks extends base_object;
    static int pre_calls = 0;
    static int post_calls = 0;
    function void pre_randomize();
      super.pre_randomize();
      pre_calls++;
    endfunction
    function void post_randomize();
      super.post_randomize();
      post_calls++;
    endfunction
  endclass
  class leaf extends hooks;
  endclass
  initial begin
    automatic leaf made = new;
    base_object base_view;
    base_view = made;
    if (!base_view.randomize()) $fatal(1, "randomize failed");
    $display("CHECK hooks %0d %0d base %0d %0d", hooks::pre_calls, hooks::post_calls,
             base_object::base_pre, base_object::base_post);
    if (hooks::pre_calls != 1 || hooks::post_calls != 1
        || base_object::base_pre != 1 || base_object::base_post != 1)
      $fatal(1, "one randomize call must invoke the hooks once");
    made.pre_randomize();
    made.post_randomize();
    if (hooks::pre_calls != 2 || hooks::post_calls != 2 ||
        base_object::base_pre != 2 || base_object::base_post != 2)
      $fatal(1, "direct inherited hooks called the wrong implementation");
    $display("CHECK pass");
    $finish;
  end
endmodule
