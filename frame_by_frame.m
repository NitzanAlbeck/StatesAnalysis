%% frame-by-frame video viewer:
% load the video:
videosPath = '/media/sil3/Data/Amphibians/Electrodes/BP30_telencephalon/2023_11_30_BP30_Trial4_Night3_4_26C_PT1/Video/videos/sleep_ir_20231130T163004.mp4';
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
currentFrame = 10;
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
