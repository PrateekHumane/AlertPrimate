% PARAMETERS %
% TODO: add sounds as param

function PARAMS = Parameters()
% -- scene 1: fixation params -- %
PARAMS.fix_radius = 3; % fixation window (in degrees):
%PARAMS.hold_radius = PARAMS.fix_radius; % radius that patient needs to hold fixation after entering fix radius
PARAMS.fix_wait_time = 3000; % time patient has to fixate before punishment
PARAMS.fix_hold_time = 200; % time patient needs to hold fixation to get reward

% -- scene 2: punishment params -- %
PARAMS.punish_box_edge_color = [1 0 0];
PARAMS.punish_box_face_color = [1 0 0];
PARAMS.punish_box_size = [12 9];
PARAMS.punish_box_position = [0 0];

PARAMS.punish_duration= 1000; % in ms

% -- scene 3: reward params-- %
PARAMS.reward_box_edge_color = [0 1 0];
PARAMS.reward_box_face_color = [0 1 0];
PARAMS.reward_box_size = [12 9];
PARAMS.reward_box_position = [0 0];

PARAMS.reward_duration= 1000; % in ms
