/*
:name: test_class_component_tree
:description: A tree of class objects that build hierarchical names from their parents
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 7.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_component_tree.expected
*/
`timescale 1ns/1ps

class component_base;
    string name;
    component_base parent;
    component_base children[$];
    
    function new(string n, component_base p = null);
        name = n;
        parent = p;
        if (p != null) begin
            p.children.push_back(this);
        end
    endfunction
    
    function string get_full_name();
        if (parent == null)
            return name;
        else
            return {parent.get_full_name(), ".", name};
    endfunction
endclass

module test_class_component_tree;
    component_base top, agent, driver, monitor;
    
    initial begin
        top = new("top");
        agent = new("agent", top);
        driver = new("driver", agent);
        monitor = new("monitor", agent);
        
        if (driver.get_full_name() == "top.agent.driver" &&
            monitor.get_full_name() == "top.agent.monitor") begin
            $display("TEST PASSED");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
