%% Hunter analysis
% Ofek sapir


%% triger map:

rec = OERecording(trig_path);

function trigMap = getTriggerMap(behave_csv_path, rec)

% this function create a .... 
% inputs: 
% * behave_CDV_path: the CSV file for one of the camares, including the
%   full path.
% * rec: OE recording.
% outputs:

% Load trigger data 
trig_path = rec.recordingDir;
trig = rec.getTrigger;

if size(trig{1},2) > 1
    trig = cell2mat(trig(1))';
elseif size(trig{1},2) == 0
    trig = cell2mat(trig(end-1))';
end
sz_trig_1 = size(trig,1);

% Load behavior data
behave = readmatrix(behave_csv_path); %upload the csv
behave = behave(:,1); % behavioral comp videos timestanps.
sz_behave = size(behave,1); % size od video triggers.
difference = diff(behave);  % diff 

% Adjust trigger data if needed
if sz_behave ~= sz_trig_1
    t_diff = diff(trig);
    row = find(t_diff >= 200);
    for i = 2:size(row,1)
        if sz_behave - 1 <= row(i) - row(i-1)
            trig = trig(row(i-1)+1:row(i)+1,:);
            sz_trig_2 = size(trig,1);
            if sz_trig_1 ~= sz_trig_2
                break;
            end
        end
    end
end

% Finding difference in trigger number between behavior and Openephys
d = abs(sz_behave - sz_trig_2);
d = d(1);
trig_diff = 'Diff in Trigger num = ' + string(d);
if d >= 1
    behave = [behave;zeros(d,1)];
    difference = [difference;zeros(d,1)];
end

% Calculate time from zero
timeFromZero = [0; cumsum(difference)];

% Create final matrix
mat = [behave, timeFromZero, trig];

% Define variable names
variableNames = {'Behavior (sec)', 'TimeFromZero (sec)', 'OE Time (ms)'};

% Write the matrix to CSV with variable names
outputDir = fullfile(rec.recordingDir, 'Trigger Map');
mkdir(outputDir);
csvFilePath = fullfile(outputDir, 'trig_map.csv');
writetable(array2table(mat, 'VariableNames', variableNames), csvFilePath);

trigMap = trig_diff;

end
