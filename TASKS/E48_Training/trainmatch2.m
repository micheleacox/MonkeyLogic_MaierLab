%trainfixation (timing script)
% modified from DMS ~MAC, Nov/Dec 2012
% continued development March/April 2013, June 2013

% This task requires that either an "eye" input or joystick (attached to the
% eye input channels) is available to perform the necessary responses.
%
% During a real experiment, a task such as this should make use of the
% "eventmarker" command to keep track of key actions and state changes (for
% instance, displaying or extinguishing an object, initiating a movement, etc).

% set editable vars
editable({'fix_radius','soft_fix_idle','prehold_fix_idle','wait_for_fix','wait_for_sac','fix_dur_LL','fix_dur_UL','pumps','reward_schedule','iti_dur_LL','iti_dur_UL','punish_dur'});

% set number of juice pumps
pumps = 1;
reward_schedule = 0; 

% give names to the TaskObjects defined in the conditions file:
acquirefix_point = 1;
holdfix_point = 2;
acquiresac_point = 3;
holdsac_point = 4;
punish_image = 5; 
distractor_point = 6;

% fixation window (in degrees):
fix_radius = 5;

% define time intervals (in ms):
% fixed intervals:
soft_fix_idle = 0;
prehold_fix_idle = 200;
wait_for_fix = 1000;
wait_for_sac = 250;
punish_dur = 2000;
% random intervals:
fix_dur_LL = 800;
fix_dur_UL = 1000;
iti_dur_LL = 1000;
iti_dur_UL = 1200;
fix_dur = randi([fix_dur_LL fix_dur_UL]);
iti_dur = randi([iti_dur_LL iti_dur_UL]);

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

% TASK:

% fixation to first location:
toggleobject(acquirefix_point);
idle(soft_fix_idle); % small idle before aquirefix initiates to emphasize fix point diffrences, also give monkey time for EM 
ontarget = eyejoytrack('acquirefix', acquirefix_point, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(acquirefix_point);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation at first location
idle(prehold_fix_idle); % short idle before holdfix initiates
toggleobject([acquirefix_point holdfix_point]);
ontarget = eyejoytrack('holdfix', holdfix_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([punish_image holdfix_point]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% turn off dot at first location, and on at second location
toggleobject([holdfix_point acquiresac_point distractor_point]);
ontarget = eyejoytrack('acquirefix', [acquiresac_point distractor_point], fix_radius, wait_for_sac);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject([ punish_image acquiresac_point distractor_point ]);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
elseif ontarget == 2,
    trialerror(6); % chose the wrong (second) object among the options [target distractor]
    toggleobject([punish_image acquiresac_point distractor_point]);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% hold fixation at second location
idle(prehold_fix_idle); % short idle before holdfix initiates
toggleobject([acquiresac_point holdsac_point]);
ontarget = eyejoytrack('holdfix', holdsac_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(5); % broke fixation
    toggleobject([punish_image holdsac_point distractor_point]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

%turn off fixation at second location
toggleobject([holdsac_point distractor_point],'status','off');
idle(50)

% correct trial reward
trialerror(0); % correct
n_pumps = uRewardSchedule(reward_schedule,pumps,TrialRecord);
goodmonkey(50, 'NumReward', n_pumps, 'PauseTime', 100);

