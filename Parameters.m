% PARAMETERS %
% TODO: add sounds as param

% -- scene 1: fixation params -- %
fix_radius = 3; % fixation window (in degrees):
hold_radius = fix_radius; % radius that patient needs to hold fixation after entering fix radius
fix_wait_time = 3000; % time patient has to fixate before punishment
fix_hold_time = 200; % time patient needs to hold fixation to get reward

% -- scene 2: punishment params -- %
punish_box_edge_color = [1 0 0];
punish_box_face_color = [1 0 0];
punish_box_size = [12 9];
punish_box_position = [0 0];

punish_duration= 1000; % in ms

% -- scene 3: reward params-- %
reward_box_edge_color = [1 0 0];
reward_box_face_color = [1 0 0];
reward_box_size = [12 9];
reward_box_position = [0 0];

reward_duration= 1000; % in ms
