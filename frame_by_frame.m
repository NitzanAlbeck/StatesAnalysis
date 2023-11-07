%% frame-by-frame video viewer:
% load the video:
videosPath = strcat(exp_path,'/block2/videos/back_20230822T130253.mp4');
vidObj = VideoReader(videosPath);

%% Choose the frame number you want to view
currentFrame = strikesFrames(6)-30; % For example, view the 50th frame
disp(currentFrame)
% Check if the chosen frame number is within the video's range
%if currentFrame <= vidObj.NumFrames
    % Read and display the frame
frame = read(vidObj, currentFrame);
imshow(frame);
%else
%disp('Frame number is out of range.');
%end

%% moving frame-by-frame:
currentFrame = 
%currentFrame = strikesFrames(10)-20;
disp(currentFrame)
while hasFrame(vidObj)
    frame = read(vidObj,currentFrame);
    imshow(frame);
    
    % Wait for a key press to advance to the next frame or exit
    key = waitforbuttonpress;
    
    if key == 0 % A key was presse
        currentFrame = currentFrame + 1;
        disp(currentFrame)
    else
        break; % Exit the loop if a key was not pressed (e.g., close figure)
    end
end
