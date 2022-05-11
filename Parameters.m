% PARAMETERS %
% TODO: add sounds as param

function PARAMS = Parameters()
% -- scene 1: fixation params -- %
PARAMS.fix_radius = 2;              % fixation window (in degrees):
                                    %PARAMS.hold_radius = PARAMS.fix_radius; % radius that patient needs to hold fixation after entering fix radius
PARAMS.fix_wait_time = 1500;        % time patient has to fixate before punishment
PARAMS.fix_hold_time = 250;         % time patient needs to hold fixation to get reward

% -- scene 2: stimulation params -- %
PARAMS.stim_fix_break_time = 1500;	% time patient has to fixate before punishment
PARAMS.stim_fix_hold_time = 600;	% time patient needs to hold fixation to get reward

PARAMS.fix2_break_time = 1500;		% time patient has to fixate before punishment
PARAMS.fix2_hold_time = 500;		% time patient needs to hold fixation to get reward

PARAMS.gray_circle_color = [0.5 0.5 0.5];
PARAMS.gray_circle_diameter = 1;

%PARAMS.stim_filename = 1; %to do trial without video
% PARAMS.stim_filename = 'flickering_low-contrast_low-sf_slow.mp4';  % trial with video, choose file to change stimulus
PARAMS.stim_filename = 'flickering_slow-contrast_high-sf_slow.mp4';
% -- scene 3: punishment params -- %
PARAMS.punish_box_edge_color = [1 0 0];
PARAMS.punish_box_face_color = [1 0 0];
PARAMS.punish_box_size = [12 9];
PARAMS.punish_box_position = [0 0];

PARAMS.punish_duration= 1500; % in ms

% -- scene 4: reward params-- %
PARAMS.reward_box_edge_color = [0 1 0];
PARAMS.reward_box_face_color = [0 1 0];
PARAMS.reward_box_size = [12 9];
PARAMS.reward_box_position = [0 0];

PARAMS.reward_duration= 500; % in ms

PARAMS.reward_juice_time = 1000; % in ms

