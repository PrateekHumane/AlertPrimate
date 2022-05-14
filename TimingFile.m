hotkey('esc', 'escape_screen(); assignin(''caller'',''continue_'',false);'); % stop on esc press
bhv_code(0, 'No Movement', 10,'Fix Cue',20,'Stimulus',30,'Punish',40,'Reward',50,'Juice');  % behavioral codes used along with eventmarker

% give names to the TaskObjects defined in the conditions file:
fix_point = 1;
punish_snd_object = 2;
reward_snd_object = 3;

% load params
PARAMS = Parameters();

% set eyetracker 
if exist('eye_','var'), tracker = eye_;
else, error('No eyetracker detected');
end

% create fixation adapter 
fix1 = SingleTarget(tracker);	% Track if gaze within threshold 
fix1.Target = fix_point;		% fixation target is taskobject1
fix1.Threshold = PARAMS.fix_radius;	% fix radius in degrees

% ------- defining scenes ------- %

% this scene can be used if more time is needed before start of trial
% -- scene 0: blank -- %
tc0 = TimeCounter(null_);
tc0.Duration = 1000;

scene0 = create_scene(tc0);

% -- scene 1: no movement -- %
pc = PulseCounter(button_); % true once a pulse is detected
pc.Button = 1;   % Button#1

tc1 = TimeCounter(null_);
tc1.Duration = PARAMS.no_movement_duration;

or1 = AndAdapter(tc1);
or1.add(pc); % end scene when movement is detected or time has finished
scene1 = create_scene(or1);


% -- scene 2: fixation -- %
% SingleTarget adapter checks if eyetracker gaze is within Threshold from Target

% WaitThenHold adapter waits for WaitTime until the fixation is acquired and then checks whether the fixation is held for HoldTime.
% wth1 = WaitThenHold(fix1);		% use fix1 as target to wait and hold on 
fth1 = FreeThenHold(fix1);
% wth1.WaitTime = PARAMS.fix_wait_time;
fth1.MaxTime = PARAMS.fix_wait_time;
fth1.HoldTime = PARAMS.fix_hold_time;

or2 = AndAdapter(fth1);
or2.add(pc);

scene2 = create_scene(or2,fix_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and wait for fixation.

% -- scene 3: stimulus -- %

lh1 = LooseHold(fix1); % hold while allowing for breaks (blinking) 
lh1.HoldTime = PARAMS.stim_fix_hold_time;
lh1.BreakTime = PARAMS.stim_fix_break_time;

gray_circle = CircleGraphic(null_);
gray_circle.EdgeColor = PARAMS.gray_circle_color;
gray_circle.FaceColor = PARAMS.gray_circle_color;
gray_circle.Size = PARAMS.gray_circle_diameter;
gray_circle.Position = [0,0];

mov = MovieGraphic(null_);
mov.List = { PARAMS.stim_filename, [0 0], 1};   % movie filename

con1 = Concurrent(lh1);
con1.add(mov);
con1.add(gray_circle);

or3 = AndAdapter(con1);
or3.add(pc);

scene3 = create_scene(or3,fix_point); % present fixation spot (TaskObject #1) concurrently with stimulus video


% -- scene 4: anticipate reward -- %

lh2 = LooseHold(fix1); % hold while allowing for breaks (blinking) 
lh2.HoldTime = PARAMS.fix2_hold_time;
lh2.BreakTime = PARAMS.fix2_break_time;

or4 = AndAdapter(lh2);
or4.add(pc);

scene4 = create_scene(or4);


% -- scene 5: reward -- %
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

scene5 = create_scene(con3); 

% -- scene 6: punishment -- %
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

scene6 = create_scene(con2,punish_snd_object); 




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
% 	0 - start
%	1 - no movement 
%	2 - fixate
%	3 - stim
% 	4 - punish
%	5 - rewardTransition 
%	6 - reward
%	7 - done
state = 1;

while state ~= 7
	switch state
		case 1
			run_scene(scene1,0);        % blank stimulus 
			if pc.Success				% if movement is detected
				state = 6;				% go to punish state
                error_code = 6;
			else
				state = 2;
			end
		case 2
			run_scene(scene2,10);        % just fixation 
			rt = fth1.AcquiredTime;      % Assign rt for the reaction time graph
			if ~fth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
				state = 6;
                error_code = 4;
			elseif pc.Success			 % if movement is detected
				state = 6;
                error_code = 6;
			else
				state = 3;
			end
		case 3
			run_scene(scene3,20);        % presents stimulus and checks fixation
			if ~lh1.Success
				state = 7;
                error_code = 3;
			elseif pc.Success			 % if movement is detected
				state = 6;
                error_code = 6;
			else
				state = 4;
			end
		case 4
			% anticipate reward
			run_scene(scene4,10);
			if ~lh2.Success				 % if animal breaks fixation
				state = 7;
                error_code = 3;
			elseif pc.Success			 % if movement is detected
				state = 6;
                error_code = 6;
			else
				state = 5;
            end
		case 5
			% run scene reward
			run_scene(scene5,50);
			goodmonkey(PARAMS.reward_juice_time, 'juiceline',1, 'numreward',1, 'pausetime',500, 'eventmarker',40); % 100 ms of juice
			state = 7;
		case 6
			% run scene punish
			run_scene(scene6,30);		
			state = 7;

	end
end

trialerror(error_code);      % Add the result to the trial history
