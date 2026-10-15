/*
:name: test_enum_name_2
:description: The enum name() method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_name_2.expected
*/
// The enum name() method
module test_enum_name;
    typedef enum {RED, GREEN, BLUE} color_t;
    color_t color;

    initial begin
        color = GREEN;

        // Test enum name() method
        if (color.name() == "GREEN") begin
            $display("enum name() test: PASSED - got %s", color.name());
        end else begin
            $display("enum name() test: FAILED - got %s, expected GREEN", color.name());
        end

        // Test different values
        color = RED;
        if (color.name() == "RED") begin
            $display("enum RED name: PASSED");
        end

        color = BLUE;
        if (color.name() == "BLUE") begin
            $display("enum BLUE name: PASSED");
        end

        $display("PASSED");
        $finish;
    end
endmodule
