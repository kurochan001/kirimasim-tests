/*
:name: test_enum_ops_2
:description: Enum next(), prev() and name()
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_ops_2.expected
*/
// Enum next(), prev() and name()
`timescale 1ns/1ps
module test_enum_ops;
    typedef enum logic [1:0] {
        IDLE = 0,
        RUN = 1,
        STOP = 2,
        ERROR = 3
    } state_e;
    
    state_e st;
    
    initial begin
        st = IDLE;
        if (st != 0) $display("FAIL: IDLE");
        
        st = st.next();
        if (st != RUN) $display("FAIL: next");
        
        st = st.next();
        if (st != STOP) $display("FAIL: next 2");
        
        st = st.prev();
        if (st != RUN) $display("FAIL: prev");
        
        st = ERROR;
        if (st.name() != "ERROR") $display("FAIL: name");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
