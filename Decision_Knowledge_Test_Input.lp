% -------------------------------------------------------
% DECISION KNOWLEDGE TEST CASES
% -------------------------------------------------------

% Operation: Screw 
% Scenario: With Washer
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
has_washer("p0","w").


% Operation: Screw 
% Scenario: Without Washer
% -------------------------------------------------------
screw_connection("sc_wo_w").
has_connected_component("sc_wo_w","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_wo_w","B",1).
has_screw_hole("B","p0").
component("B").

has_connection_point("sc_wo_w","p0",0).
has_screw("p0","s").


% Operation: Screw 
% Scenario: With Nut
% -------------------------------------------------------
screw_connection("sc_w_n").
has_connected_component("sc_w_n","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_w_n","B",1).
has_screw_hole("B","p0").
component("B").

has_connection_point("sc_w_n","p0",0).
has_screw("p0","s").
has_nut("p0","n").

% Operation: Screw 
% Scenario: Without Nut
% -------------------------------------------------------
screw_connection("sc_w_n").
has_connected_component("sc_w_n","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_w_n","B",1).
has_screw_hole("B","p0").
component("B").

has_connection_point("sc_w_n","p0",0).
has_screw("p0","s").


% Operation: Screw 
% Scenario: With Pluginnut
% -------------------------------------------------------
screw_connection("sc_w_pn").
has_connected_component("sc_w_pn","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_w_pn","B",1).
has_screw_hole("B","p0").
has_pluginnut("p0","pn","B").
component("B").

has_connection_point("sc_w_pn","p0",0).
has_screw("p0","s").


% Operation: Screw 
% Scenario: Without Pluginnut
% -------------------------------------------------------
screw_connection("sc_w_pn").
has_connected_component("sc_w_pn","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_w_pn","B",1).
has_screw_hole("B","p0").
component("B").

has_connection_point("sc_w_pn","p0",0).
has_screw("p0","s").


% Operation: Screw 
% Scenario: With Longhole
% -------------------------------------------------------
screw_connection("sc_lh").
has_connected_component("sc_lh","A",0).
has_screw_hole("A","p0").
component("A").

has_connected_component("sc_lh","B",1).
has_screw_hole("B","p0").
component("B").
has_hole("B",p0,"longhole").

has_connection_point("sc_lh","p0",0).
has_screw("p0","s").




% Operation: Glue 
% Scenario: Liquid Glue
% -------------------------------------------------------
glue_connection("gc_lg").
has_connection_point("gc_lg","p0").

has_connected_component("gc_lg","A",0).
has_connected_component("gc_lg","B",1).

glue_type("gc_lg","liquid").


% Operation: Glue 
% Scenario: Tape
% -------------------------------------------------------
glue_connection("gc_t").
has_connection_point("gc_t","p0").

has_connected_component("gc_t","A",0).
has_connected_component("gc_t","B",1).

glue_type("gc_t","tape").



% Operation: Glue 
% Scenario: Self Adhesive
% -------------------------------------------------------
glue_connection("gc_sa").
has_connection_point("gc_sa","p0").

has_connected_component("gc_sa","A",0).
has_connected_component("gc_sa","B",1).

glue_type("gc_sa","self adhesive").



% Operation: Glue 
% Scenario: Self Adhesive Sticker
% -------------------------------------------------------
glue_connection("gc_sas").
has_connection_point("gc_sas","p0").

has_connected_component("gc_sas","A",0).
has_connected_component("gc_sas","B",1).

sticker("B").
glue_type("gc_sas","self adhesive").

