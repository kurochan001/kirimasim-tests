/*
:name: test_vpi_variable_class_member_props
:description: Variables give vpiRandType (rand, randc or not random), vpiIsRandomized (whether a random property is enabled, following rand_mode), vpiVisibility (local, protected or public, public for non-members), vpiConstantVariable (TRUE for const variables) and vpiAllocScheme (dynamic for properties of a class object, other for static variables) (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.3.7 37.31 37.33 8.18 18.4 18.8 6.20.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_class_member_props.c
:expected_stdout: @test_vpi_variable_class_member_props.expected
*/
// IEEE 1800-2023 §37.17: vpiRandType is vpiRand, vpiRandC or vpiNotRand
// (details 15 and 22; rand and randc, 18.4): ra, rc and the other properties
// of rc_c. vpiIsRandomized tells whether a random variable is active for
// randomization (detail 16): the design turns off ra of the object o with
// rand_mode(0) (18.8), so for the properties of o (37.33) it is FALSE for ra,
// TRUE for rc and FALSE for the non-random plain. vpiVisibility (detail 24,
// 8.18) is vpiLocalVis for lo, vpiProtectedVis for pr and vpiPublicVis for
// plain and for the module variable mv, which is no class member.
// vpiConstantVariable is TRUE for the const class property cp and the const
// module variable mc (6.20.6) and FALSE for plain and mv. vpiAllocScheme
// (37.3.7) is vpiDynamicScheme for plain and ra of the object o, which belong
// to it, and vpiOtherScheme for the static property st and for mv. The class
// defn rc_c (37.31) gives the declared properties.

module test_vpi_variable_class_member_props;
  class rc_c;
    rand int ra;
    randc bit [1:0] rc;
    int plain;
    local int lo;
    protected int pr;
    static int st;
    const int cp = 3;
  endclass

  rc_c o = new;
  int mv = 1;
  const int mc = 4;

  initial begin
    o.ra.rand_mode(0);
    #1 $vt_props;
  end
endmodule
