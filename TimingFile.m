hotkey('esc', 'escape_screen(); assignin(''caller'',''continue_'',false);'); % stop on esc press
bhv_code(10,'Fix Cue',20,'Stimulus',30,'Punish',40,'Reward',50,'Juice');  % behavioral codes used along with eventmarker

% set eyetracker 
if exist('eye_','var'), tracker = eye_;
else, error('No eyetracker detected');
end

% give names to the TaskObjects defined in the conditions file:
fix_point = 1;
punish_snd_object = 2;
reward_snd_object = 3;

% TODO: possibly load params into param object?
PARAMS = Parameters();

% ------- defining scenes ------- %

% this scene can be used if more time is needed before start of trial
% -- scene 0: blank -- %
%tc0 = TimeCounter(null_);
%tc0.Duration = 1000;
%
%scene0 = create_scene(tc0);

% -- scene 1: fixation -- %
% SingleTarget adapter checks if eyetracker gaze is within Threshold from Target

fix1 = SingleTarget(tracker);	% Track if gaze within threshold 
fix1.Target = fix_point;		% fixation target is taskobject1
fix1.Threshold = PARAMS.fix_radius;	% fix radius in degrees

% WaitThenHold adapter waits for WaitTime until the fixation is acquired and then checks whether the fixation is held for HoldTime.
% wth1 = WaitThenHold(fix1);		% use fix1 as target to wait and hold on 
wth1 = FreeThenHold(fix1);
% wth1.WaitTime = PARAMS.fix_wait_time;
wth1.MaxTime = PARAMS.fix_wait_time;
wth1.HoldTime = PARAMS.fix_hold_time;

scene1 = create_scene(wth1,fix_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and wait for fixation.

% -- scene 2: stimulus -- %

fix2 = SingleTarget(tracker);	% Track if gaze within threshold 
fix2.Target = fix_point;		% fixation target is taskobject1
fix2.Threshold = PARAMS.fix_radius;	% fix radius in degrees

fth2 = FreeThenHold(fix1);
fth2.MaxTime = PARAMS.fix_wait_time;
fth2.HoldTime = PARAMS.fix_hold_time;

mov = MovieGraphic(null_);
mov.List = { '1.mov', [0 0], 1};   % movie filename

con1 = Concurrent(fth2);
con1.add(mov);

scene2 = create_scene(con1,fix_point); % present fixation spot (TaskObject #1) concurrently with stimulus video

% -- scene 3: punishment -- %
punish_box = BoxGraphic(null_);
punish_box.EdgeColor = PARAMS.punish_box_edge_color;
punish_box.FaceColor = PARAMS.punish_box_face_color;
punish_box.Size = PARAMS.punish_box_size;
punish_box.Position = PARAMS.punish_box_position;

punish_snd = AudioSound(null_);
% punish_snd.List = 'bad.wav';
% punish_snd.PlaybackPosition = 0;

tc1 = TimeCounter(null_);
tc1.Duration = PARAMS.punish_duration;

con2 = Concurrent(tc1);
con2.add(punish_box);
con2.add(punish_snd);

scene3 = create_scene(con2,punish_snd_object); 

% -- scene 4: reward -- %
reward_box = BoxGraphic(null_);
reward_box.EdgeColor = PARAMS.reward_box_edge_color;
reward_box.FaceColor = PARAMS.reward_box_face_color;
reward_box.Size = PARAMS.reward_box_size;
reward_box.Position = PARAMS.reward_box_position;

reward_snd = AudioSound(null_);
reward_snd.List = 'bell.wav';

tc2 = TimeCounter(null_);
tc2.Duration = PARAMS.reward_duration;

con3 = Concurrent(tc2);
con3.add(reward_box);
con3.add(reward_snd);

scene4 = create_scene(con3); 


% ------- running task ------- %

% list of all error codes for reference:
%    0 - Correct
%    1 - No response
%    2 - Late response
%    3 - Break fixation
%    4 - No fixation
%    5 - Early response
%    6 - Incorrect
%    7 - Lever break
%    8 - Ignored
%    9 - Aborted

% start error code at 0
error_code = 0;

% list of all states:
%	0 - fixate
%	1 - stim
% 	2 - punish
%	3 - rewardTransition 
%	4 - reward
%	5 - done
state = 0;

while state ~= 5
	switch state
		case 0
			run_scene(scene1,10);        % Run the first scene (eventmaker 10)
			rt = wth1.AcquiredTime;      % Assign rt for the reaction time graph
			if ~wth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
				state = 2;				 % Next state is 
                error_code = 4;
%			    if wth1.Waiting          % Check whether we were waiting for fixation.
%			        error_code = 4;      % If so, fixation was never made and therefore this is a "no fixation (4)" error.
%			    else
%			        error_code = 3;      % If we were not waiting, it means that fixation was acquired but not held,
%			    end
			else
				state = 1;
			end
		case 1
			run_scene(scene2,20);        % Run the first scene (eventmaker 10)
			rt = fth2.AcquiredTime;      % Assign rt for the reaction time graph
			if ~fth2.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
				state = 2;				 % Next state is 
                error_code = 4;
			else
				state = 3;
			end
		case 2
			% run scene punish
			run_scene(scene3,30);		
			state = 4;
		case 3
			% anticipate reward
			run_scene(scene1,10);
			state = 4;
		case 4
			% run scene reward
			run_scene(scene4,40);
			goodmonkey(PARAMS.reward_juice_time, 'juiceline',1, 'numreward',1, 'pausetime',500, 'eventmarker',40); % 100 ms of juice
			state = 5;

	end
end
idle(50);
trialerror(error_code);      % Add the result to the trial history
