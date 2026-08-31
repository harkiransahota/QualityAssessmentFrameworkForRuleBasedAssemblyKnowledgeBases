% -------------------------------------------------------
% ENGINEERING RULE COVERAGE TEST CASES
% -------------------------------------------------------

% Rule: ER1
% Description: Safety-relevant threaded connections require documentation and torque-controlled tightening.

% -------------------------------------------------------
screw_connection("sc_w_w").
has_connected_component("sc_w_w","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_w_w","B",1).
has_screw_hole("B","p0").
component("B").

has_connection_point("sc_w_w","p0",0).
has_screw("p0","s").

safety_relevant("sc_w_w","s").