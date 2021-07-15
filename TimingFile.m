hotkey('esc', 'escape_screen(); assignin(''caller'',''continue_'',false);'); % stop on esc press
bhv_code(10,'Fix Cue',20,'Punish',30,'Reward',40,'Juice');  % behavioral codes used along with eventmarker

% set eyetracker 
if exist('eye_','var'), tracker = eye_;
else, error('No eyetracker detected');
end

% give names to the TaskObjects defined in the conditions file:
fix_point = 1;
punish_snd_object = 2;
reward_snd_object = 3;

% TODO: possibly load params into param object?
PARAMS = TASK_PARAMETERS();

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
wth1 = WaitThenHold(fix1);		% use fix1 as target to wait and hold on 
wth1.WaitTime = PARAMS.fix_wait_time;
wth1.HoldTime = PARAMS.fix_hold_time;

scene1 = create_scene(wth1,fix_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and wait for fixation.

% -- scene 2: punishment -- %
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

con1 = Concurrent(tc1);
con1.add(punish_box);
con1.add(punish_snd);

scene2 = create_scene(con1,punish_snd_object); 

% -- scene 3: reward -- %
reward_box = BoxGraphic(null_);
reward_box.EdgeColor = PARAMS.reward_box_edge_color;
reward_box.FaceColor = PARAMS.reward_box_face_color;
reward_box.Size = PARAMS.reward_box_size;
reward_box.Position = PARAMS.reward_box_position;

reward_snd = AudioSound(null_);
reward_snd.List = 'bell.wav';

tc2 = TimeCounter(null_);
tc2.Duration = PARAMS.reward_duration;

con2 = Concurrent(tc2);
con2.add(reward_box);
con2.add(reward_snd);

scene3 = create_scene(con2); 


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
% 	1 - punish
%	2 - reward
%	3 - done
state = 0;

while state ~= 3
	switch state
		case 0
			run_scene(scene1,10);        % Run the first scene (eventmaker 10)
			rt = wth1.AcquiredTime;      % Assign rt for the reaction time graph
			if ~wth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
				state = 1;				 % Next state is 
			    if wth1.Waiting          % Check whether we were waiting for fixation.
			        error_code = 4;      % If so, fixation was never made and therefore this is a "no fixation (4)" error.
			    else
			        error_code = 3;      % If we were not waiting, it means that fixation was acquired but not held,
			    end
			else
				state = 2;
			end
		case 1
			% run scene punish
			run_scene(scene2,20);		
			state = 3;
		case 2
			% run scene reward
			run_scene(scene3,30);
			goodmonkey(100, 'juiceline',1, 'numreward',1, 'pausetime',500, 'eventmarker',40); % 100 ms of juice
			state = 3;
	end
end
idle(50);
trialerror(error_code);      % Add the result to the trial history
