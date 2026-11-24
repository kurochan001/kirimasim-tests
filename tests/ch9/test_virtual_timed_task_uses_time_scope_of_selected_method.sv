/*
:name: test_virtual_timed_task_uses_time_scope_of_selected_method
:description: An inherited timed task keeps the base package time scale and an override uses its own package scale
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 3.14.1 3.14.2.2 8.20 26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_timed_task_uses_time_scope_of_selected_method.expected
*/
package timeline_base;
  timeunit 10ns;
  timeprecision 1ns;

  class scheduled;
    virtual task step(input realtime interval, output int method_tag);
      method_tag = 1;
      #(interval);
    endtask
  endclass
endpackage

package timeline_derived;
  timeunit 1ns;
  timeprecision 10ps;

  class inherited extends timeline_base::scheduled;
  endclass

  class overridden extends timeline_base::scheduled;
    virtual task step(input realtime interval, output int method_tag);
      method_tag = 2;
      #(interval);
    endtask
  endclass
endpackage

module test_virtual_timed_task_uses_time_scope_of_selected_method;
  timeunit 1ps;
  timeprecision 1ps;

  task automatic sample(input timeline_base::scheduled object_ref, input realtime interval,
                        input string label_text);
    time started;
    int method_tag;
    started = $time;
    object_ref.step(interval, method_tag);
    $display("%s method=%0d elapsed=%0d", label_text, method_tag, $time - started);
  endtask

  initial begin
    timeline_derived::inherited inherited_instance;
    timeline_derived::overridden overridden_instance;
    inherited_instance = new;
    overridden_instance = new;
    #1;
    sample(inherited_instance, 0.046, "inherited small");
    sample(overridden_instance, 0.046, "override small");
    sample(inherited_instance, 0.256, "inherited large");
    sample(overridden_instance, 0.256, "override large");
    $finish(0);
  end
endmodule
