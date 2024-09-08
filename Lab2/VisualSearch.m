clc
close all
clear all

% HW2 Neurosciense Lab , Spring 1403r
% Value-based visual search
% Amirhossein Zahedi 99101705

%%%%%%%%%%%%%%%%%%%% Subject inputs %%%%%%%%%%%%%%%%%%%%r
subject_name = input("Please enter your name:","s");
subject_ID = input("Please enter your ID:"); 
session_number = input("Please enter session number:");
trials_number = input("How many trials are you considering?:");
distance = input("How distant is you eye from monitor in cm?:");

%%%%%%%%%%%%%%%%%%%% Defining first part of outputs %%%%%%%%%%%%%%%%%%%%
output = struct;
output.subjectName = subject_name;
output.subjectID = subject_ID;
output.sessionNumber = session_number;
output.trials = struct;
output.trials.buttonPressed = cell(trials_number,1);
output.trials.fractalsName = cell(trials_number,9);
output.trials.fractalsPosition = cell(trials_number,1);
output.trials.DS = cell(trials_number,1);
output.trials.valueORperceptual = cell(trials_number,1);
output.trials.absentORpresent = cell(trials_number,1);
output.trials.mousePosition = cell(trials_number,1);

%%%%%%%%%%%%%%%%%%%% Data reading %%%%%%%%%%%%%%%%%%%%
img_dir = 'Assignment2_fractals\';
file_list = dir([img_dir '*.jpeg']);
all_fractals = cell(48, 1);
for i = 1:length(file_list)
    filename = [img_dir file_list(i).name];
    all_fractals{i} = imread(filename);
end

[audData, audFreq ] = audioread('beep-1-sec-6162.mp3');
reward_img = imread('reward.png');
value_img = imread('value group.png');
perceptual_img = imread('perceptual group.png');
mouse_img = imread('mouse click.png');
R_img = imread('R press.png');

%%%%%%%%%%%%%%%%%%%% Data grouping %%%%%%%%%%%%%%%%%%%%
% randomizing fractals
sorted_fractals = cell(48,1);
random_perm = randperm(length(all_fractals));
sorted_fractals = all_fractals(random_perm);
sorted_file_list = file_list(random_perm,:);

% making cells
value_good_img = cell(12,1);
perceptual_good_img = cell(12,1);
value_bad_img = cell(12,1);
perceptual_bad_img = cell(12,1);

% grouping images
value_good_img = sorted_fractals(1:12);
perceptual_good_img = sorted_fractals(13:24);
value_bad_img = sorted_fractals(25:36);
perceptual_bad_img = sorted_fractals(37:48);

% grouping lists
value_good_list = sorted_file_list(1:12,:);
perceptual_good_list = sorted_file_list(13:24,:);
value_bad_list = sorted_file_list(25:36,:);
perceptual_bad_list = sorted_file_list(37:48,:);


%%%%%%%%%%%%%%%%%%%% Trials making %%%%%%%%%%%%%%%%%%%%
% randomizing trials display size
trials_ds = [3*ones(1,trials_number/4),5*ones(1,trials_number/4),7*ones(1,trials_number/4),9*ones(1,trials_number/4)].';
trials_ds = trials_ds(randperm(trials_number));

% randomizing trials present or absent
trials_ap = [ones(1,trials_number/4),2*ones(1,trials_number/4),3*ones(1,trials_number/4),4*ones(1,trials_number/4)].';
trials_ap = trials_ap(randperm(trials_number));

% randomizing trials degree
trials_degree = randi([1, 360], trials_number, 1);

% randomizing good fractals
a = 1:12;
a = [a,a,a].';
value_good_fractals_list = a(randperm(36));
perceptual_good_fractals_list = a(randperm(36));

%%%%%%%%%%%%%%%%%%%% Screen making %%%%%%%%%%%%%%%%%%%%
PsychDebugWindowConfiguration();
PsychDefaultSetup(0);
backgroundColor = BlackIndex(0);
[window, windowRect] = PsychImaging('OpenWindow', 0, backgroundColor);
[~, ~] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('Preference','FrameRectCorrection', 1);

%%%%%%%%%%%%%%%%%%%% Keyboard defining %%%%%%%%%%%%%%%%%%%%
kQ = KbName('q');          
kSp = KbName('space');  
kR = KbName('r');  
key = nan;

%%%%%%%%%%%%%%%%%%%% Epoch durations %%%%%%%%%%%%%%%%%%%%
duration_img = 3;
waitframes_img = round(duration_img / ifi);
duration_ITI_reward = 1.5;
waitframes_ITI_reward = round(duration_ITI_reward / ifi);
duration_ITI_reject = 0.2;
waitframes_ITI_reject = round(duration_ITI_reject / ifi);

%%%%%%%%%%%%%%%%%%%% Text fetures %%%%%%%%%%%%%%%%%%%%
Screen('TextSize', window, 20);
Screen('TextStyle', window, 1);
Screen('TextFont', window, 'Times New Roman');

%%%%%%%%%%%%%%%%%%%% First scene %%%%%%%%%%%%%%%%%%%%
first_scene_img = imread('first scene.png');
imageTexture = Screen('MakeTexture', window, first_scene_img);
W_first = windowRect(:,3)/1.5;
R_fisrt = windowRect(:,4)/1.5;
Screen('DrawTexture', window, imageTexture, [], [xCenter-W_first/2 yCenter-R_fisrt/2 xCenter+W_first/2 yCenter+R_fisrt/2], 0);
HideCursor;
Screen('Flip', window); 

%%%%%%%%%%%%%%%%%%%% Main cycle %%%%%%%%%%%%%%%%%%%%
t_value = 0;
t_perceptual = 0;

while ~(key == kSp || key == kQ)
        [ keyIsDown, ~, keyCode ] = KbCheck(-1);
        if (keyIsDown)
            key = find(keyCode);
        end
end

rejected_numbers = 0;
for i = 1:trials_number
    
    %%%%%%%%%%%%%%%%%%%% Center scene %%%%%%%%%%%%%%%%%%%%
    duration_fix = randi([300 500],1)/1000;
    waitframes_fix = round(duration_fix / ifi);
    time_fix = GetSecs;
    Screen('DrawDots', window, [xCenter, yCenter], 20, [255 255 255], [], 2);
    Screen('Flip', window);
    Screen('Flip', window, time_fix + (waitframes_fix) * ifi);

    %%%%%%%%%%%%%%%%%%%% Image locations %%%%%%%%%%%%%%%%%%%%
    R = 650;
    W = 350;
    loc = zeros(trials_ds(i),2);
    for j = 1:trials_ds(i)
        degree = (360/trials_ds(i))*j + trials_degree(i);
        degree = deg2rad(degree);
        loc(j,1) = round(R*cos(degree)) + xCenter;
        loc(j,2) = round(R*sin(degree)) + yCenter;
    end

    %%%%%%%%%%%%%%%%%%%% Defining second part of outputs %%%%%%%%%%%%%%%%%%%%
    output.fractalSize = atan((W*0.025/2)/distance)*180/pi;
    output.peripheralCircuit = atan((R*0.025)/distance)*180/pi;
    output.screenSize = windowRect(3:4);

    %%%%%%%%%%%%%%%%%%%% Image defining & setting %%%%%%%%%%%%%%%%%%%%
    images = cell(trials_ds(i),1);
    switch trials_ap(i)
        case 1
            t_value = t_value + 1;
            images{1} = value_good_img{value_good_fractals_list(t_value)};
            output.trials.fractalsName{i,1} = value_good_list(value_good_fractals_list(t_value)).name;
            imageTexture = Screen('MakeTexture', window, images{1});
            Screen('DrawTexture', window, imageTexture, [], [loc(1,1)-W/2 loc(1,2)-W/2 loc(1,1)+W/2 loc(1,2)+W/2], 0);
            Screen('FrameRect', window, [0,255,0],[loc(1,1)-W/2 loc(1,2)-W/2 loc(1,1)+W/2 loc(1,2)+W/2],5);

            rp = randperm(12,trials_ds(i));
            for j = 2:trials_ds(i)
                images{j} = value_bad_img{rp(j)};
                output.trials.fractalsName{i,j} = perceptual_bad_list(rp(j)).name;
                imageTexture = Screen('MakeTexture', window, images{j});
                Screen('DrawTexture', window, imageTexture, [], [loc(j,1)-W/2 loc(j,2)-W/2 loc(j,1)+W/2 loc(j,2)+W/2], 0);
            end
        case 2
            rp = randperm(12,trials_ds(i));
            for j = 1:trials_ds(i)
                images{j} = value_bad_img{rp(j)};
                output.trials.fractalsName{i,j} = value_bad_list(rp(j)).name;
                imageTexture = Screen('MakeTexture', window, images{j});
                Screen('DrawTexture', window, imageTexture, [], [loc(j,1)-W/2 loc(j,2)-W/2 loc(j,1)+W/2 loc(j,2)+W/2], 0);
            end
        case 3
            t_perceptual = t_perceptual + 1;
            images{1} = value_good_img{perceptual_good_fractals_list(t_perceptual),1};
            output.trials.fractalsName{i,1} = perceptual_good_list(perceptual_good_fractals_list(t_perceptual)).name;
            imageTexture = Screen('MakeTexture', window, images{1});
            Screen('DrawTexture', window, imageTexture, [], [loc(1,1)-W/2 loc(1,2)-W/2 loc(1,1)+W/2 loc(1,2)+W/2], 0);
            Screen('FrameRect', window, [0,255,0],[loc(1,1)-W/2 loc(1,2)-W/2 loc(1,1)+W/2 loc(1,2)+W/2],5);

            rp = randperm(12,trials_ds(i));
            for j = 2:trials_ds(i)
                images{j} = perceptual_bad_img{rp(j)};
                output.trials.fractalsName{i,j} = perceptual_bad_list(rp(j)).name;
                imageTexture = Screen('MakeTexture', window, images{j});
                Screen('DrawTexture', window, imageTexture, [], [loc(j,1)-W/2 loc(j,2)-W/2 loc(j,1)+W/2 loc(j,2)+W/2], 0);
            end
        otherwise
            rp = randperm(12,trials_ds(i));
            for j = 1:trials_ds(i)
                images{j} = perceptual_bad_img{rp(j)};
                output.trials.fractalsName{i,j} = perceptual_bad_list(rp(j)).name;
                imageTexture = Screen('MakeTexture', window, images{j});
                Screen('DrawTexture', window, imageTexture, [], [loc(j,1)-W/2 loc(j,2)-W/2 loc(j,1)+W/2 loc(j,2)+W/2], 0);
            end
    end

    %%%%%%%%%%%%%%%%%%%% Image showing %%%%%%%%%%%%%%%%%%%%
    Screen('DrawDots', window, [xCenter, yCenter], 20, [255 255 255], [], 2);
    time_img = GetSecs;
    Screen('Flip', window,[],1);
    
    %%%%%%%%%%%%%%%%%%%% Response scene %%%%%%%%%%%%%%%%%%%%
    error_flag = 0;
    clicked = 0; 
    reward = 0;
    ShowCursor;
    SetMouse(xCenter, yCenter, window);
    mouse_dots = zeros(0,2);
    mouse_dots_numbers = 0;
    while ~(key == kQ || key == kR || error_flag == 1 || clicked == 1)
        %%%%%%%%%%%%%%%%%%%% Mouse click %%%%%%%%%%%%%%%%%%%%
        mouse_dots_numbers = mouse_dots_numbers + 1;
        [x,y,buttons] = GetMouse();
        mouse_dots(mouse_dots_numbers,1) = x;
        mouse_dots(mouse_dots_numbers,2) = y;
        if (buttons(1) == 1)
            for j = 1:trials_ds(i)
                if (x>loc(j,1)-W/2 && x<loc(j,1)+W/2 && y>loc(j,2)-W/2 && y<loc(j,2)+W/2)
                    clicked = 1;
                    if j == 1 && (trials_ap(i) == 1 || trials_ap(i) == 3)
                        reward = 1;
                    end
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%% Keyboard %%%%%%%%%%%%%%%%%%%%
        if (error_flag == 0)
            [ keyIsDown, ~, keyCode ] = KbCheck(-1);
            if (keyIsDown)
                key = find(keyCode);
            end
        end

        %%%%%%%%%%%%%%%%%%%% Not responding %%%%%%%%%%%%%%%%%%%%
        delta = GetSecs-time_img;
        if (delta > 3)
            error_flag = 1;
            key = kSp;
        end
    end
    unique_mouse_dots = unique(mouse_dots,'rows','stable');

    %%%%%%%%%%%%%%%%%%%% Analyzing resposes %%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%% Beep %%%%%%%%%%%%%%%%%%%%
    if (error_flag == 1)
        t_beep = GetSecs;
        sound(audData,audFreq);
        Screen('Flip', window);
        Screen('Flip', window);
        Screen('Flip', window, t_beep + (waitframes_ITI_reward)* ifi);

    %%%%%%%%%%%%%%%%%%%% Reject %%%%%%%%%%%%%%%%%%%%
    elseif (key == kR)
        if trials_ap(i) == 2 || trials_ap(i) == 4
            rejected_numbers = rejected_numbers + 1;
        else
            rejected_numbers = 0;
        end
        key = kSp;
        t_ITI_reject = GetSecs;
        %%%%%%%%%%%%%%%%%%%% Reject without reward %%%%%%%%%%%%%%%%%%%%
        if rejected_numbers < 3
            switch trials_ap(i)
                case 1
                    imageTexture = Screen('MakeTexture', window, value_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
                case 3
                    imageTexture = Screen('MakeTexture', window, perceptual_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
                case 2
                    imageTexture = Screen('MakeTexture', window, value_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
                case 4
                    imageTexture = Screen('MakeTexture', window, perceptual_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            end
            imageTexture = Screen('MakeTexture', window, R_img);
            Screen('DrawTexture', window, imageTexture, [], [150 250 500 500], 0);
            HideCursor;
            Screen('Flip', window);
            Screen('Flip', window, t_ITI_reject + (waitframes_ITI_reject)* ifi);

        %%%%%%%%%%%%%%%%%%%% Reject with reward %%%%%%%%%%%%%%%%%%%%
        else
            w_reward = 100;
            x_reward = 230;
            y_reward = 450;
            rejected_numbers = 0;
            switch trials_ap(i)
                case 1
                    imageTexture = Screen('MakeTexture', window, value_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
                case 3
                    imageTexture = Screen('MakeTexture', window, perceptual_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
                case 2
                    imageTexture = Screen('MakeTexture', window, value_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
                case 4
                    imageTexture = Screen('MakeTexture', window, perceptual_img);
                    Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            end
            imageTexture = Screen('MakeTexture', window, R_img);
            Screen('DrawTexture', window, imageTexture, [], [150 250 500 500], 0);
            imageTexture = Screen('MakeTexture', window, reward_img);
            Screen('DrawTexture', window, imageTexture, [], [x_reward y_reward x_reward+w_reward y_reward+w_reward], 0);
            Screen('DrawTexture', window, imageTexture, [], [x_reward+100 y_reward x_reward+100+w_reward y_reward+w_reward], 0);
            Screen('DrawTexture', window, imageTexture, [], [x_reward+50 y_reward+100 x_reward+50+w_reward y_reward+100+w_reward], 0);
            HideCursor;
            Screen('Flip', window);
            Screen('Flip', window, t_ITI_reject + (waitframes_ITI_reward)* ifi);
        end
        output.trials.buttonPressed{i} = 'Reject';

    %%%%%%%%%%%%%%%%%%%% Quit %%%%%%%%%%%%%%%%%%%%
    elseif (key == kQ)
        clear Screen;

    %%%%%%%%%%%%%%%%%%%% Click with reward %%%%%%%%%%%%%%%%%%%%
    elseif reward == 1
        t_click = GetSecs;
        w_reward = 100;
        x_reward = 230;
        y_reward = 450;
        switch trials_ap(i)
            case 1
                imageTexture = Screen('MakeTexture', window, value_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            case 3
                imageTexture = Screen('MakeTexture', window, perceptual_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            case 2
                imageTexture = Screen('MakeTexture', window, value_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            case 4
                imageTexture = Screen('MakeTexture', window, perceptual_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
        end
        imageTexture = Screen('MakeTexture', window, mouse_img);
        Screen('DrawTexture', window, imageTexture, [], [150 250 500 500], 0);
        imageTexture = Screen('MakeTexture', window, reward_img);
        Screen('DrawTexture', window, imageTexture, [], [x_reward y_reward x_reward+w_reward y_reward+w_reward], 0);
        Screen('DrawTexture', window, imageTexture, [], [x_reward+100 y_reward x_reward+100+w_reward y_reward+w_reward], 0);
        Screen('DrawTexture', window, imageTexture, [], [x_reward+50 y_reward+100 x_reward+50+w_reward y_reward+100+w_reward], 0);
        for j = 1:size(unique_mouse_dots,1)
            Screen('DrawDots', window, [unique_mouse_dots(j,1), unique_mouse_dots(j,2)], 20, [255-mod(j,256) 255 mod(j,256)], [], 2);
        end
        HideCursor;
        Screen('Flip', window);
        Screen('Flip', window, t_click + (waitframes_ITI_reward)* ifi);
        output.trials.buttonPressed{i} = 'Accept';

    %%%%%%%%%%%%%%%%%%%% Click without reward %%%%%%%%%%%%%%%%%%%%
    else
        t_click = GetSecs;
        w_reward = 100;
        x_reward = 230;
        y_reward = 450;
        switch trials_ap(i)
            case 1
                imageTexture = Screen('MakeTexture', window, value_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            case 3
                imageTexture = Screen('MakeTexture', window, perceptual_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            case 2
                imageTexture = Screen('MakeTexture', window, value_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
            case 4
                imageTexture = Screen('MakeTexture', window, perceptual_img);
                Screen('DrawTexture', window, imageTexture, [], [150 100 500 350], 0);
        end
        imageTexture = Screen('MakeTexture', window, mouse_img);
        Screen('DrawTexture', window, imageTexture, [], [150 250 500 500], 0);
        imageTexture = Screen('MakeTexture', window, reward_img);
        Screen('DrawTexture', window, imageTexture, [], [x_reward+50 y_reward x_reward+50+w_reward y_reward+w_reward], 0);
        for j = 1:size(unique_mouse_dots,1)
            Screen('DrawDots', window, [unique_mouse_dots(j,1), unique_mouse_dots(j,2)], 20, [255-mod(j,256) 255 mod(j,256)], [], 2);
        end
        HideCursor;
        Screen('Flip', window);
        Screen('Flip', window, t_click + (waitframes_ITI_reward)* ifi);
        output.trials.buttonPressed{i} = 'Accept';
    end
    
    %%%%%%%%%%%%%%%%%%%% Defining third part of outputs %%%%%%%%%%%%%%%%%%%%
    output.trials.fractalsPosition{i} = loc;
    output.trials.DS{i} = trials_ds(i);
    switch trials_ap(i)
        case 1
            output.trials.valueORperceptual{i} = 'value';
            output.trials.absentORpresent{i} = 'TP';
        case 2
            output.trials.valueORperceptual{i} = 'value';
            output.trials.absentORpresent{i} = 'TA';
        case 3
            output.trials.valueORperceptual{i} = 'perceptual';
            output.trials.absentORpresent{i} = 'TP';
        case 4
            output.trials.valueORperceptual{i} = 'perceptual';
            output.trials.absentORpresent{i} = 'TA';
    end
    output.trials.mousePosition{i} = unique_mouse_dots;

end

%%%%%%%%%%%%%%%%%%%% Saving results %%%%%%%%%%%%%%%%%%%%
result_name = 'Result_' + string(subject_ID) + '_' + string(session_number) + '_' + subject_name + '.mat';
save(result_name,"output");

clear Screen;
sca;