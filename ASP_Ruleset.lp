% -----------------------------------
% General Rules
% -----------------------------------

has_base(X,COMP):-connection(X), has_connected_component(X,COMP,0).

connection_point(POINT) :- screw_point(POINT) .

connection(X) :- screw_connection(X) .
connection(X) :- screw_clamp_connection(X) .
connection(X) :- plugin_connection(X) .
connection(X) :- welding_connection(X) .
connection(X) :- glue_connection(X) .
connection(X) :- push_connection(X).
connection(X) :- coat_requirement(X).
connection(X) :- thread_connection(X).

connection(X) :- drill_requirement(X).
requirement(X):-drill_requirement(X).

component(X) :- has_connected_component(_,X,_).
component(X) :- has_processed_component(_,X).
component(X) :- assembly_component(X) .
component(X) :- screw(X) .
component(X) :- nut(X) .
component(X) :- washer(X) .
component(X) :- cable(X).

component_connection(COMP,CONN) :- component(COMP), has_connected_component(CONN,COMP,_) .
component_connection_count(COMP,COUNT) :- component(COMP), COUNT = #count{CONN : component_connection(COMP,CONN)} .
component_connection_step(COMP,CONN,STEP) :- component_connection(COMP,CONN), plan_connection(CONN,STEP) .
component_first_connection(COMP,CONN) :- MIN = #min{STEP : component_connection_step(COMP,_,STEP)}, component_connection_step(COMP,CONN,MIN) .

washer(X) :- spring_washer(X) .
screw(X) :- hex_head_screw(X) .
screw(X):-has_screw(_,X).
nut(X) :- hex_nut(X) .

tool("Socket Wrench",tool_id_socket_wrench).
tool("Screw Driver Default",tool_id_default_screw_driver).
tool("Screw Driver Slotted",tool_id_slotted).
tool("Screw Driver Philips",tool_id_philips).
tool("Hand",tool_id_hand).
tool("Allen Wrench",tool_id_allen_wrench).
default_tool("Screw Driver Default",tool_id_default_screw_driver).


%tool(X) :- screw_driver(X) .
%tool(X) :- wrench(X) .


%Define default screwing tools according to screw head type
is_for("Hand",SCREW) :-  screw(SCREW), has_head(SCREW,_,"hand_grip") .
is_for("Socket Wrench",SCREW) :- tool("Socket Wrench",_), screw(SCREW), has_head(SCREW,_,"hex") .
is_for("Socket Wrench",NUT) :- tool("Socket Wrench",_), nut(NUT), has_shape(NUT,"hex") .
is_for("Screw Driver Philips",SCREW) :- tool("Screw Driver Philips",_),screw(SCREW), has_head(SCREW,_,"Philips") .
is_for("Screw Driver Slotted",SCREW) :- tool("Screw Driver Slotted",_),screw(SCREW), has_head(SCREW,_,"slot") .
is_for("Allen Wrench",SCREW) :- tool("Allen Wrench",_),screw(SCREW), has_head(SCREW,_,"allen") .


has_head_details(SCREW):-has_head(SCREW,_,_).
is_for("Screw Driver Default",SCREW):- screw(SCREW), not has_head_details(SCREW).




has_component(X,COMP) :- has_screw(X,COMP) .
has_component(X,COMP) :- has_nut(X,COMP) .
has_component(X,COMP) :- has_washer(X,COMP) .

component(COMP) :- has_matching(X,COMP,Y) .


% Rules for additional operation information
% The needed instance informations are defined in components.lp
% ----------------------------------

%assign according tightening tool using is_for rule
tighten_with(CONN,STEP,COMP,ID,SIZE,none) :- action(tighten,CONN,POINT,COMP,STEP), is_for(TOOL,COMP), tool(TOOL,ID), has_head(COMP,SIZE,_),not safety_relevant(CONN,COMP).
tighten_with(CONN,STEP,COMP,ID,none,none) :- action(tighten,CONN,POINT,COMP,STEP), is_for(TOOL,COMP), tool(TOOL,ID), not has_head(COMP,_,_), not safety_relevant(CONN,COMP).
tighten_with(CONN,STEP,COMP,ID,none,none) :- action(tighten,CONN,POINT,COMP,STEP), is_for("Hand",COMP), has_head(COMP,_,_), tool("Hand",ID), not safety_relevant(CONN,COMP).
tighten_with(CONN,STEP,COMP,ID,none,none) :- action(tighten_nut,CONN,POINT,COMP,STEP), tool("Socket Wrench",ID).
tighten_with(CONN,STEP,COMP,ID,"15","Nm") :- action(tighten,CONN,POINT,COMP,STEP), safety_relevant(CONN,COMP), tool("Socket Wrench",ID).
#show tighten_with/6 .


position_with(CONN,STEP,COMP,"Hand") :- action(position,CONN,_,COMP,STEP) .
position_with(CONN,STEP,COMP,"2AK") :- action(position,CONN,_,COMP,STEP), weight(COMP,X), X>100 .
position_with(CONN,STEP,COMP,"2AK") :- action(position,CONN,_,COMP,STEP), size(COMP,X), X>100 .
#show position_with/4 .

insert_with(CONN,STEP,COMP,OBJ,"Hand") :- action(insert,CONN,POINT,COMP,STEP), has_screw(POINT,COMP), has_matching(POINT,_,COMP), has_matching(POINT,_,OBJ), COMP != OBJ .
insert_with(CONN,STEP,COMP,OBJ,"Hand") :- action(insert,CONN,POINT,COMP,STEP), has_screw(POINT,COMP), not has_matching(POINT,_,COMP), has_matching(POINT,_,OBJ), COMP != OBJ .
#show insert_with/5 .

adjust_with(CONN,STEP,COMP,"Hand") :- action(adjust,CONN,_,COMP,STEP) .
#show adjust_with/4 .

turnon_with(CONN,STEP,COMP,SCREW,"Hand") :- action(turnon,CONN,PONIT,COMP,STEP), has_nut(POINT,COMP), has_screw(POINT,SCREW) .
%#show turnon_with/5 .

sub_action(CONN, STEP,0,COMP_1,COMP_2,POINT, "plug in") :- action(plugin,CONN,COMP_1,COMP_2,STEP), has_connection_point(CONN,POINT).
plugin_with(CONN,STEP,COMP_2,"Hand") :- action(plugin,CONN,_,COMP_2,STEP) .
#show plugin_with/4 .



% -----------------------------------
% Processing Rules
% -----------------------------------

%in every step handle exactly one connection
connection_step(0..END-1) :- END = #count{CONN: connection(CONN)} .

1{plan_connection(CONN,STEP): connection(CONN)}1 :- connection_step(STEP) .

:- plan_connection(CONN,STEP_A), plan_connection(CONN,STEP_B), STEP_A != STEP_B .
:- plan_connection(CONN_A,STEP_A), plan_connection(CONN_B,STEP_B),plan_connection(CONN_C,STEP_C), component_connect_connections_together(COMP,ID,CONN_A),component_connect_connections_together(COMP,ID,CONN_B),component_connect_connections_together(COMP_C,ID_C,CONN_C),COMP_C != COMP, STEP_A < STEP_C, STEP_C < STEP_B .
:- plan_connection(CONN,STEP), start_connection(CONN), STEP > 0 .

action(assemble,CONN,none,none,STEP) :- plan_connection(CONN,STEP), not requirement(CONN) . 
action(execute,CONN,none,none,STEP) :- plan_connection(CONN,STEP), requirement(CONN) . 


% ------ Action -----------------------------

action(ACTION,CONN,A,B,SUM + 1 + SUB_STEP) :- action(ACTION,CONN,A,B,STEP_A,SUB_STEP), SUM = #sum{S,STEP : sub_actions(CONN,STEP,S), STEP < STEP_A} .
optional_info(CONN,SUM + 1 + SUB_STEP,"optional") :- optional_info(CONN,_,STEP_A,SUB_STEP), SUM = #sum{S,STEP : sub_actions(CONN,STEP,S), STEP < STEP_A} .

% -----------------------------------
% RESULT Filters
% -----------------------------------

#show action/5 .
#show optional_info/3 .



% -----------------------------------
% Operation Rules
% -----------------------------------


%:Screw_Planning_LP a asp:RuleSet;


screw_connection_start(CONN,END) :- screw_connection(CONN), END = 0 .
screw_connection_end(CONN,END) :- screw_tighten_end(CONN,END) .

% Position Components Planning Rules
% -----------------------------------

conn_component_count(CONN, COUNT) :-COUNT = #count{COMP : has_connected_component(CONN,COMP,ORDER),ORDER!=0},has_connected_component(CONN,_,_).

single_component_connection(CONN) :-conn_component_count(CONN,0). 

screw_assemble_start(CONN,STEP) :- screw_connection_start(CONN,STEP) .
screw_assemble_range(CONN,START,COUNT) :- screw_assemble_start(CONN,START),conn_component_count(CONN, COUNT).
screw_step_assemble(CONN,STEP) :- screw_assemble_range(CONN,START,COUNT), STEP= START..COUNT, not single_component_connection(CONN).
screw_assemble_end(CONN,COUNT+1) :- screw_assemble_start(CONN,STEP), conn_component_count(CONN,COUNT).

action(position,CONN,none,COMP,0,0) :- screw_step_assemble(CONN,0), has_connected_component(CONN,COMP,0).

%no plugin nuts
action(position,CONN,COMP_A,COMP_B,SUB_STEP,0) :- screw_step_assemble(CONN,SUB_STEP), has_connected_component(CONN,COMP_B,SUB_STEP),has_connected_component(CONN,COMP_A,SUB_STEP-1), has_connection_point(CONN,POINT,_),not has_pluginnut(POINT,_,COMP_B) .

%with plugin nuts
action(insert_pluginnut,CONN,COMP_B,PLUGINNUT,SUB_STEP,0) :- screw_step_assemble(CONN,SUB_STEP), has_connected_component(CONN,COMP_B,SUB_STEP),has_connected_component(CONN,COMP_A,SUB_STEP-1), has_connection_point(CONN,POINT,_), has_pluginnut(POINT,PLUGINNUT,COMP_B) .
action(position,CONN,COMP_A,COMP_B,SUB_STEP,1) :- screw_step_assemble(CONN,SUB_STEP), has_connected_component(CONN,COMP_B,SUB_STEP),has_connected_component(CONN,COMP_A,SUB_STEP-1), has_connection_point(CONN,POINT,_), has_pluginnut(POINT,_,COMP_B) .


sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_step_assemble(CONN,STEP) .

% Screw Point Planning Rules
% -----------------------------------

conn_point_count(CONN, COUNT) :-COUNT = #count{POINT : has_connection_point(CONN,POINT,_)},has_connection_point(CONN,_,_).


screw_insert_start(CONN,STEP+1) :- screw_assemble_end(CONN,STEP), single_component_connection(CONN).
screw_insert_start(CONN,STEP+1) :- screw_assemble_end(CONN,STEP), not single_component_connection(CONN) .
screw_insert_range(CONN,START,COUNT) :- screw_insert_start(CONN,START), conn_point_count(CONN, COUNT) .
screw_step_insert(CONN,STEP) :- screw_insert_range(CONN,START,COUNT), STEP=START..START+COUNT-1.
screw_insert_end(CONN,STEP+COUNT) :- screw_insert_start(CONN,STEP), conn_point_count(CONN, COUNT). 


% 1{screw_action(POINT,CONN,STEP): has_connection_point(CONN,POINT)}1 :- screw_step_insert(CONN,STEP) .
% :- screw_action(POINT,CONN,STEP_A), screw_action(POINT,CONN,STEP_B), STEP_A != STEP_B .

screw_action(POINT,CONN,STEP) :- has_connection_point(CONN,POINT,SEQ),screw_insert_range(CONN,START,_),STEP = START + SEQ.

%if has nut, no screw
action(turnon,CONN,POINT,COMP,STEP,0) :- screw_action(POINT,CONN,STEP), has_nut(POINT,COMP), not has_screw(POINT,_) .

%if has washer
action(position_washer,CONN,POINT,COMP,STEP,0) :- screw_action(POINT,CONN,STEP), has_washer(POINT,COMP), not has_pluginnut(POINT,_),has_screw(POINT,_) .
action(insert,CONN,POINT,COMP,STEP,1) :- screw_action(POINT,CONN,STEP), has_screw(POINT,COMP), has_washer(POINT,_), not has_pluginnut(POINT,_)  .
%if has nut
action(turnon,CONN,POINT,COMP,STEP,2) :- screw_action(POINT,CONN,STEP), has_nut(POINT,COMP), has_washer(POINT,_), not has_pluginnut(POINT,_),has_screw(POINT,_) .


%if no washer
action(insert,CONN,POINT,COMP,STEP,0) :- screw_action(POINT,CONN,STEP), has_screw(POINT,COMP), not has_washer(POINT,_), not has_pluginnut(POINT,_) .
%if has nut
action(turnon,CONN,POINT,COMP,STEP,1) :- screw_action(POINT,CONN,STEP), has_nut(POINT,COMP), not has_washer(POINT,_), not has_pluginnut(POINT,_),has_screw(POINT,_)  .


sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), screw_step_insert(CONN,STEP)}, screw_step_insert(CONN,STEP) .


% Adjust Planning Rules
% -----------------------------------
screw_adjust_start(CONN,STEP+1) :- screw_insert_end(CONN,STEP) .
screw_adjust_range(CONN,START,COUNT):-screw_adjust_start(CONN,START), conn_component_count(CONN, COUNT) .
screw_step_adjust(CONN,STEP) :- screw_adjust_range(CONN,START,COUNT), STEP=START..START+COUNT-1.
screw_adjust_end(CONN,STEP+COUNT) :- screw_adjust_start(CONN,STEP), conn_component_count(CONN, COUNT) .

1{adjust_action(none,CONN,COMP,STEP,0): has_connected_component(CONN,COMP,_)}1 :- screw_step_adjust(CONN,STEP) .

:- adjust_action(POINT,CONN,COMP,STEP_A,0), adjust_action(POINT,CONN,COMP,STEP_B,0), STEP_A != STEP_B .

%if the component is a design part or the hole is a longhole adjust
action(adjust,CONN,POINT,COMP,STEP,0) :- adjust_action(POINT,CONN,COMP,STEP,0), has_hole(COMP,_,"longhole").
action(adjust,CONN,POINT,COMP,STEP,0) :- adjust_action(POINT,CONN,COMP,STEP,0), design_part(COMP).

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_step_adjust(CONN,STEP) .

% Tighten Planning Rules
% -----------------------------------
screw_tighten_start(CONN,STEP+1) :- screw_adjust_end(CONN,STEP) .
screw_tighten_range(CONN,START,COUNT):- screw_tighten_start(CONN,START), conn_point_count(CONN, COUNT).
screw_step_tighten(CONN,STEP) :- screw_tighten_range(CONN,START,COUNT), STEP=START..START+COUNT-1.
screw_tighten_end(CONN,STEP+COUNT) :- screw_tighten_start(CONN,STEP), conn_point_count(CONN, COUNT).


tighten_action(POINT,CONN,STEP) :- has_connection_point(CONN,POINT,SEQ), screw_tighten_range(CONN,START,_),STEP = START + SEQ.
%same point cannot be tightened in multiple times
:- tighten_action(POINT,CONN,STEP_A), tighten_action(POINT,CONN,STEP_B), STEP_A != STEP_B .



%either tighten nut (if there is a nut) or tighten screw 
point_has_nut(POINT):-has_nut(POINT,NUT).
action(tighten,CONN,POINT,COMP,STEP,0) :- tighten_action(POINT,CONN,STEP), has_screw(POINT,COMP), not point_has_nut(POINT).
action(tighten_nut,CONN,POINT,COMP,STEP,0) :- tighten_action(POINT,CONN,STEP), has_nut(POINT,COMP).


sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, tighten_action(_,CONN,STEP) .


%:Screw_Clamp_Planning_LP a asp:RuleSet;

% Position Components Planning Rules
% -----------------------------------

screw_clamp_position_start(CONN,STEP+1) :- screw_clamp_prepro_end(CONN,STEP) .
screw_clamp_position_end(CONN,STEP) :- screw_clamp_position_start(CONN,STEP) .

action(position,CONN,POINT,COMP,STEP,0) :- screw_clamp_position_start(CONN,STEP), has_connected_component(CONN,COMP,1), has_connection_point(CONN,POINT).%, has_base(CONN,LOCATION) .

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_clamp_position_start(CONN,STEP) .


% Adjust Planning Rules
% -----------------------------------

screw_clamp_adjust_start(CONN,STEP+1) :- screw_clamp_position_end(CONN,STEP) .
screw_clamp_step(CONN,screw_clamp_adjust_step(START..START+END-1)) :- screw_clamp_adjust_start(CONN,START), END = #count{POINT : has_connection_point(CONN,POINT)} .
screw_clamp_adjust_end(CONN,STEP+COUNT) :- screw_clamp_adjust_start(CONN,STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.

1{adjust_action(CONN,POINT,STEP): has_connection_point(CONN,POINT)}1 :- screw_clamp_step(CONN,screw_clamp_adjust_step(STEP)) .

:- adjust_action(CONN,POINT,STEP_A), adjust_action(CONN,POINT,STEP_B), STEP_A != STEP_B .

%the first nut at every connection point is used for adjusting
action(adjust,CONN,POINT,NUT,STEP,0) :- adjust_action(CONN,POINT,STEP), selected_nut_order(POINT,NUT,0) .

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_clamp_adjust_start(CONN,STEP) .


% Tightening Planning Rules
% -----------------------------------

screw_clamp_tighten_start(CONN,STEP+1) :- screw_clamp_adjust_end(CONN,STEP) .
screw_clamp_step(CONN,screw_clamp_tighten_step(START..START+END-1)) :- screw_clamp_tighten_start(CONN,START), END = #count{POINT : has_connection_point(CONN,POINT)} .
screw_clamp_tighten_end(CONN,STEP) :- screw_clamp_adjust_start(CONN,STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.

1{tighten_action(CONN,POINT,STEP): has_connection_point(CONN,POINT)}1 :- screw_clamp_step(CONN,screw_clamp_tighten_step(STEP)) .

:- tighten_action(CONN,POINT,STEP_A), tighten_action(CONN,POINT,STEP_B), STEP_A != STEP_B .

%remaining nuts at the connection points are simply tightened
action(tighten,CONN,POINT,NUT,STEP,SUB_STEP) :- tighten_action(CONN,POINT,STEP), -first_nut(POINT,NUT), selected_nut_order(POINT,NUT,SUB_STEP) .

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y)}, screw_clamp_tighten_start(CONN,STEP) . 



%:Glue_Planning_LP a asp:RuleSet;

glue_connection_start(CONN,END+1) :- glue_connection(CONN), END = 0 .
glue_connection_end(CONN,END) :- glue_stick_on_end(CONN,END) .


% Prepare Components Planning Rules
% -----------------------------------

glue_prepare_start(CONN,STEP):-glue_connection_start(CONN,STEP).
%create a glue step for preparing for every component in the connection
glue_step(CONN,glue_prepare_step(START..START+COUNT-1)) :- glue_prepare_start(CONN,START), not glue_type(CONN, "self adhesive"), COUNT = #count{COMP : has_connected_component(CONN,COMP,_)} .
glue_step(CONN,glue_prepare_step(START..START)) :- glue_prepare_start(CONN,START), glue_type(CONN, "self adhesive") .
glue_prepare_end(CONN, STEP+COUNT) :- glue_prepare_start(CONN, STEP), COUNT = #count{COMP : has_connected_component(CONN,COMP,_)}.

%per glue step assign exactly one component to be handled in glue action
1{glue_action(CONN,COMP,STEP): has_connected_component(CONN,COMP,_)}1 :- glue_step(CONN,glue_prepare_step(STEP)), not glue_type(CONN, "self adhesive") .
glue_action(CONN,COMP,STEP) :- glue_step(CONN,glue_prepare_step(STEP)),has_connected_component(CONN,COMP,0),glue_type(CONN,"self adhesive") .
%constraint: one glue action handling the same component cannot occure in different time steps
:- glue_action(CONN,COMP,STEP_A), glue_action(CONN,COMP,STEP_B), STEP_A != STEP_B .

%defining actions with according sub step - glue connection with liquid glue
action(grind,CONN,COMP,none,STEP,0)  :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,0)  :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
action(clean,CONN,COMP,none,STEP,1) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
action(mask,CONN,COMP,none,STEP,2) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,2) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
action(prime,CONN,COMP,none,STEP,3) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .
	optional_info(CONN,COMP,STEP,3) :- glue_action(CONN,COMP,STEP), glue_type(CONN, "liquid") .

%defining actions with according sub step - glue connection with other than liquid glue
action(clean,CONN,COMP,none,STEP,0) :- glue_action(CONN,COMP,STEP), not glue_type(CONN, "liquid") .
%action(prime,CONN,COMP,none,STEP,1) :- glue_action(CONN,COMP,STEP), not glue_type(CONN, "liquid") .
%	optional_info(CONN,COMP,STEP,1) :- glue_action(CONN,COMP,STEP), not glue_type(CONN, "liquid") .
%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_prepare_step(STEP))}, glue_step(CONN,glue_prepare_step(STEP)) .


% Prepare Adhesive Planning Rules
% -----------------------------------

glue_prepare_adhesive_start(CONN,STEP):-glue_prepare_end(CONN,STEP).
glue_step(CONN, glue_prepare_adhesive_step(STEP..STEP)):-glue_prepare_adhesive_start(CONN,STEP).
glue_prepare_adhesive_end(CONN, STEP+1) :- glue_prepare_adhesive_start(CONN, STEP).

prepare_adhesive(CONN,COMP_A,COMP_B,STEP):- glue_step(CONN, glue_prepare_adhesive_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1).

action(equip_glue_equipment,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid").

action(remove_film,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"),has_connected_component(CONN,COMP_B,1), not sticker(COMP_B) .
%if the self adhesive part is a sticker or label it may have to be cut to length first
action(cut_to_length,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"), has_connected_component(CONN,COMP_B,1), sticker(COMP_B) .
action(remove_film,CONN,COMP_A,COMP_B,STEP,1):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"),has_connected_component(CONN,COMP_B,1), sticker(COMP_B) .


action(cut_to_length,CONN,COMP_A,COMP_B,STEP,0):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "tape") .
action(remove_film,CONN,COMP_A,COMP_B,STEP,1):- prepare_adhesive(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "tape") .

%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_prepare_adhesive_step(STEP))}, glue_step(CONN,glue_prepare_adhesive_step(STEP)) .


% Apply Adhesive Planning Rules
% -----------------------------------

glue_apply_adhesive_start(CONN,STEP):- glue_prepare_adhesive_end(CONN,STEP), not glue_type(CONN, "self adhesive"). 
%one glue step per connection point
glue_step(CONN, glue_apply_adhesive_step(STEP..STEP+COUNT-1)):- glue_apply_adhesive_start(CONN,STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.
glue_apply_adhesive_end(CONN, STEP+COUNT) :- glue_apply_adhesive_start(CONN, STEP), COUNT = #count{POINT : has_connection_point(CONN,POINT)}.

1{apply_adhesive(CONN,POINT,STEP): has_connection_point(CONN,POINT)}1 :- glue_step(CONN, glue_apply_adhesive_step(STEP)).
:- apply_adhesive(CONN,POINT,STEP_A), apply_adhesive(CONN,POINT,STEP_B), STEP_A != STEP_B .
apply_adhesive(CONN,COMP_A,POINT,STEP):- apply_adhesive(CONN,POINT,STEP), has_connected_component(CONN,COMP_A,0).

%for liquid, apply adhesive for every point 
action(apply_glue,CONN,COMP,POINT,STEP,0) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "liquid" ).
%if glue point is an area, glue as to be spread
action(spread_glue,CONN,COMP,POINT,STEP,1) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP,STEP,1) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "liquid" ).


%double sided tape, apply tape on base and remove film on other side
action(apply_tape,CONN,COMP,POINT,STEP,0) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "tape" ) .
action(remove_film,CONN,COMP,POINT,STEP,1) :- apply_adhesive(CONN,COMP,POINT,STEP), glue_type(CONN, "tape" ) .

%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_apply_adhesive_step(STEP))}, glue_step(CONN,glue_apply_adhesive_step(STEP)) .


% Stick On Planning Rules
% -----------------------------------
	
glue_stick_on_start(CONN,STEP) :- glue_apply_adhesive_end(CONN,STEP), not glue_type(CONN, "self adhesive").
glue_stick_on_start(CONN,STEP) :- glue_prepare_adhesive_end(CONN,STEP), glue_type(CONN, "self adhesive").
glue_step(CONN, glue_stick_on_step(STEP..STEP)):- glue_stick_on_start(CONN,STEP).
glue_stick_on_end(CONN, STEP+1) :- glue_stick_on_start(CONN, STEP).

stick_on_part(CONN,COMP_A,COMP_B,STEP):- glue_step(CONN, glue_stick_on_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1).

action(stick_on,CONN,COMP_A,COMP_B,STEP,0):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
action(remove_excess_glue,CONN,COMP_A,COMP_B,STEP,1) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,1) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
%remove masking tape that was applied in prepare step
action(remove_tape,CONN,COMP_A,COMP_B,STEP,2):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,2):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
action(fix_with_equipment,CONN,COMP_A,COMP_B,STEP,3) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,3):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
action(remove_equipment,CONN,COMP_A,COMP_B,STEP,4) :- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).
	optional_info(CONN,COMP_A,STEP,4):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "liquid" ).

action(stick_on,CONN,COMP_A,COMP_B,STEP,0):-stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive").
%in case the self adhesive part is a sticker or label smoothen it after sticking on
action(smoothen,CONN,COMP_A,COMP_B,STEP,1) :-stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "self adhesive"), sticker(COMP_B) .


action(stick_on,CONN,COMP_A,COMP_B,STEP,0):- stick_on_part(CONN,COMP_A,COMP_B,STEP), glue_type(CONN, "tape" ).

%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), glue_step(CONN,glue_stick_on_step(STEP))}, glue_step(CONN,glue_stick_on_step(STEP)) .


%:Plugin_Planning_LP a asp:RuleSet;

plugin_connection_start(CONN,END) :- plugin_connection(CONN), END = 0 .
plugin_connection_end(CONN,END) :- plugin_assemble_end(CONN,END) .


% Assemble Planning Rules
% -----------------------------------

plugin_plugin_start(CONN,STEP) :- plugin_connection_start(CONN,STEP) .
plugin_step(CONN,plugin_plugin_step(START..START)) :- plugin_plugin_start(CONN,START) .
plugin_assemble_end(CONN,STEP+1) :- plugin_plugin_start(CONN,STEP).

action(position,CONN,COMP_A,COMP_B,STEP,0) :- plugin_step(CONN,plugin_plugin_step(STEP)), has_connection_point(CONN,POINT), has_connected_component(CONN,COMP_A,SUB_STEP-1), has_connected_component(CONN,COMP_B,SUB_STEP), COMP_A != COMP_B, has_base(CONN,COMP_A).


action(plugin,CONN,COMP_A,COMP_B,STEP,1) :- plugin_step(CONN,plugin_plugin_step(STEP)), has_connection_point(CONN,POINT), has_connected_component(CONN,COMP_A,SUB_STEP-1), has_connected_component(CONN,COMP_B,SUB_STEP), COMP_A != COMP_B, has_base(CONN,COMP_A).

action(secure,CONN,none,STRING,STEP,2) :- plugin_step(CONN,plugin_plugin_step(STEP)), has_connection_point(CONN,POINT), has_connected_component(CONN,COMP_A,SUB_STEP-1), has_connected_component(CONN,COMP_B,SUB_STEP), COMP_A != COMP_B, has_base(CONN,COMP_A), has_secure_string(CONN,COMP,STRING).
											
action(cut_to_length,CONN,none,STRING,STEP,3) :- plugin_step(CONN,plugin_plugin_step(STEP)), has_connection_point(CONN,POINT), has_connected_component(CONN,COMP_A,SUB_STEP-1),has_connected_component(CONN,COMP_B,SUB_STEP), COMP_A != COMP_B, has_base(CONN,COMP_A), has_secure_string(CONN,COMP,STRING).


sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), plugin_step(CONN,plugin_plugin_step(STEP))}, plugin_step(CONN,plugin_plugin_step(STEP)) .


%:Drill_Planning_LP a asp:RuleSet;

drill_requirement_start(CONN,END) :- drill_requirement(CONN), END = 0 .
drill_requirement_end(CONN,END) :- drill_drill_end(CONN,END) .


% Drill Planning Planning Rules
% -----------------------------------

drill_drill_start(CONN,STEP) :- drill_requirement_start(CONN,STEP) .
drill_step(CONN,drill_drill_step(START..START)) :- drill_drill_start(CONN,START) .
drill_drill_end(CONN,STEP+1) :- drill_drill_start(CONN,STEP).


action(drill,CONN,COMP,POINT,STEP,0) :- drill_step(CONN,drill_drill_step(STEP)), has_drill_point(CONN,POINT), has_component(CONN,COMP,SUB_STEP).

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), drill_step(CONN,drill_drill_step(STEP))}, drill_step(CONN,drill_drill_step(STEP)) .

hole(POINT) :- action(drill,CONN,_,_,_,_), has_drill_point(CONN,POINT).



%:Welding_Planning_LP a asp:RuleSet;

welding_connection_start(CONN,END + 1) :- welding_connection(CONN), END = 0 .
welding_connection_end(CONN,END) :- weld_assemble_end(CONN,END) .

% Position Components Planning Rules
% -----------------------------------

weld_assemble_start(CONN,STEP) :- welding_connection_start(CONN,STEP) .
weld_step(CONN,weld_assemble_step(START..START)) :- weld_assemble_start(CONN,START).
weld_assemble_end(CONN,STEP) :- weld_assemble_start(CONN,STEP), COUNT != 0, COUNT = #count{COMP : has_connected_component(CONN,COMP,ORDER), ORDER != 0}.

position_welding_component(CONN_A,COMP_A,COMP_B,STEP,SUB_STEP-1) :- weld_step(CONN_A,weld_assemble_step(STEP)), has_connected_component(CONN_A,COMP_A,SUB_STEP-1), has_connected_component(CONN_A,COMP_B,SUB_STEP), component_first_connection(COMP_B,CONN_A) .


action(position,CONN_A,COMP_A,COMP_B,STEP,SUB_STEP-1) :- position_welding_component(CONN_A,COMP_A,COMP_B,STEP,SUB_STEP-1) .

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), weld_step(CONN,weld_assemble_step(STEP))}, weld_step(CONN,weld_assemble_step(STEP)) .


% Weld Planning Rules
% -----------------------------------

weld_weld_start(CONN,STEP+1) :- weld_assemble_end(CONN,STEP) .
weld_step(CONN,weld_weld_step(START..START)) :- weld_weld_start(CONN,START).
weld_weld_end(CONN,STEP) :- weld_weld_start(CONN,STEP), COUNT != 0, COUNT = #count{COMP : has_connected_component(CONN,COMP,ORDER), ORDER != 0}.

1{weld_action(CONN,POINT,STEP): has_connection_point(CONN,POINT)}1 :- weld_step(CONN,weld_weld_step(STEP)) .

:- weld_action(CONN,POINT,STEP_A), weld_action(CONN,POINT,STEP_B), STEP_A != STEP_B .


action(weld,CONN,COMP_A,COMP_B,STEP,0) :- weld_action(CONN,POINT,STEP), has_weld(POINT,_), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1). 

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), weld_step(CONN,weld_weld_step(STEP))}, weld_step(CONN,weld_weld_step(STEP)) .



%:Documentation_Planning_LP a asp:RuleSet;

documentation_requirement_start(CONN,S,END + 1) :- safety_relevant(CONN,S),screw_connection_end(CONN,END).
documentation_reqiurement_end(CONN,END) :- documentation_screw_end(CONN,END) .


% Document Planning Rules
% -----------------------------------

documentation_screw_start(CONN,S,STEP) :- documentation_requirement_start(CONN,S,STEP).
documentation_step(CONN,S,documentation_screw_step(START..START)) :- documentation_screw_start(CONN,S,START).
documentation_screw_end(CONN,START+1) :- documentation_screw_start(CONN,S,START).

%1{document_screw_point(CONN,POINT,STEP):has_connection_point(CONN,POINT)}1 :- documentation_step(CONN,documentation_screw_step(STEP)).
%:- document_screw_point(CONN,POINT,STEP_A), document_screw_point(CONN,POINT,STEP_B), STEP_A != STEP_B .

action(document,CONN,S,none,STEP,0) :- documentation_step(CONN,S,documentation_screw_step(STEP)).

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), documentation_step(CONN,S,documentation_screw_step(STEP))}, documentation_step(CONN,S,documentation_screw_step(STEP)) .



%:Coat_Planning_LP a asp:RuleSet;

coat_requirement_start(CONN,END) :- coat_requirement(CONN), END = 0 .
coat_requirement_end(CONN,END) :- coat_coat_end(CONN,END) .


% Coat Planning Rules
% -----------------------------------

coat_coat_start(CONN,0) :- coat_requirement_start(CONN,STEP) .
coat_step(CONN,coat_coat_step(START..START)) :- coat_coat_start(CONN,START) .
coat_coat_end(CONN,STEP+1) :- coat_coat_start(CONN,STEP).
	
action(apply_fhm,CONN,COMP,none,STEP,0) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP).
action(position_in_fixture,CONN,COMP,none,STEP,1) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP). 
action(grind,CONN,COMP,none,STEP,2) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP). 
action(clean_rough,CONN,COMP,none,STEP,3) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP). 
action(clean_fine,CONN,COMP,none,STEP,4) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP). 
action(coat_base,CONN,COMP,none,STEP,5) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP). 
action(coat_clear,CONN,COMP,none,STEP,6) :- coat_step(CONN,coat_coat_step(STEP)),has_processed_component(CONN,COMP).
									
%counting number of sub actions 
sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,COMP,_,STEP,Y), coat_step(CONN,coat_coat_step(STEP))}, coat_step(CONN,coat(STEP)).



%:Pushin_Planning_LP a asp:RuleSet;

push_connection_start(CONN,END) :- push_connection(CONN), END = 0 .
push_connection_end(CONN,END) :- push_assemble_end(CONN,END) .


% Assemble Planning Rules
% -----------------------------------

push_assemble_start(CONN,STEP) :- push_connection_start(CONN,STEP) .
push_step(CONN,push_assemble_step(START..START)) :- push_assemble_start(CONN,START) .
push_assemble_end(CONN,STEP+1) :- push_assemble_start(CONN,STEP).

action(position,CONN,COMP_A,COMP_B,STEP,0) :- push_step(CONN,push_assemble_step(STEP)),	has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1), not cut_part(COMP_B),  COMP_A != COMP_B.


action(push_in,CONN,COMP_A,COMP_B,STEP,1) :- push_step(CONN,push_assemble_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1), not cut_part(COMP_B),  COMP_A != COMP_B.

%if part is cut part, cut first then push in
action(set_up_cutting_table,CONN,none,none,STEP,0) :- push_step(CONN,push_assemble_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1), cut_part(COMP_B), COMP_A != COMP_B.
action(cut_to_length,CONN,none,COMP_B,STEP,1) :- push_step(CONN,push_assemble_step(STEP)), has_connected_component(CONN,COMP_A,0),  has_connected_component(CONN,COMP_B,1), cut_part(COMP_B), COMP_A != COMP_B.
action(position,CONN,COMP_A,COMP_B,STEP,2) :- push_step(CONN,push_assemble_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1), cut_part(COMP_B), COMP_A != COMP_B.										
action(push_in,CONN,COMP_A,COMP_B,STEP,3) :- push_step(CONN,push_assemble_step(STEP)), has_connected_component(CONN,COMP_A,0), has_connected_component(CONN,COMP_B,1), cut_part(COMP_B), COMP_A != COMP_B.

sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), push_step(CONN,push_assemble_step(STEP))}, push_step(CONN,push_assemble_step(STEP)) .



%:Threading_Planning_LP a asp:RuleSet;

threading_connection_start(CONN,END) :- thread_connection(CONN), END = 0 .
threading_connection_end(CONN,END) :- threading_assemble_end(CONN,END) .


% Threading Planning Rules
% -----------------------------------

threading_through_start(CONN,STEP) :- threading_connection_start(CONN,STEP) .
threading_step(CONN,thread_through_step(START..START)) :- threading_through_start(CONN,START).
threading_assemble_end(CONN,STEP+1) :- threading_through_start(CONN,STEP).

action(thread,CONN,COMP,CABLE,STEP,SEQ) :- threading_step(CONN,thread_through_step(STEP)), has_threading_component(CONN,POS,COMP,SEQ), has_threaded_component(CONN,CABLE).


sub_actions(CONN,STEP,S) :- S = #count{Y : action(_,CONN,_,_,STEP,Y), threading_step(CONN,thread_through_step(STEP))}, threading_step(CONN,thread_through_step(STEP)) .

