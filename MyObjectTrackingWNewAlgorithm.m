% Take Video - Extract Frames
% Read Frames and compare to last frame
% Extract all differences
% Look for Min/max of each difference location
% Plot X in center

function MyObjectTracking


% Live feed to image goes HERE
% enter imaqhwinfo to get device ID (winvideo below)
%then dev_info = imaqhwinfo('adaptername(winvideo below)', 'adapternumbernormally 1')
vid = videoinput('winvideo',1,'YUY2_320x240'); %The highest resolution of my camera
ran_once = 0;
vidWidth = 320;
vidHeight =240;
scale = 1; %scale in half - still get a resonable picture
vidWidth = vidWidth*scale;
vidHeight = vidHeight*scale;
tollerance = 150;
oldXmid = vidHeight/2;
oldYmid = vidWidth/2;
while(1),

preview(vid);
data = getsnapshot(vid);
data = imresize(data, scale);


%Begin YuY2 to RGB conversion 
%(Comment everything below out if using RGB camera)
P = single(data(:,:,1));
U = single(data(:,:,2));
V = single(data(:,:,3));

C = P-16;
D = U - 128;
E = V - 128;


R = uint8((298*C+409*E+128)/256);
G = uint8((298*C-100*D-208*E+128)/256);
B = uint8((298*C+516*D+128)/256);

newdata = uint8(zeros(size(data)));
newdata(:,:,1)=R;
newdata(:,:,2)=G;
newdata(:,:,3)=B;
%End YUY2 to RGB conversion
%newdata = data; %Uncomment if using RGB camera

%
%Uncomment up to Xmax to do premade video tracking
%
%DanceObj = VideoReader('fish.avi');
%nFrames = DanceObj.NumberOfFrames;
%vidHeight = DanceObj.Height;
%vidWidth = DanceObj.Width;
%vidFrameRate = ceil(DanceObj.FrameRate);
%vidFrameRate = 30;
%mov(1:nFrames) = ...
%   struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
%    'colormap', []);   
%totruns = nFrames;
%totruns = 1;
%startframe =1;
%

Xmax=0;
Ymax=0;
Xmin = vidHeight;
Ymin = vidWidth;


total = size(newdata);
newimage = newdata;
if ran_once == 1,
tic 
total = abs(newimage(:,:,:) - M(:,:,:,1));

for X=1:vidHeight,        
    for Y=1:vidWidth,
        if total(X,Y,:) > tollerance,
          if(X > Xmax),
             Xmax = X;
          end
          if(X < Xmin),
             Xmin = X;
          end
          if(Y > Ymax),
             Ymax = Y;
          end   
          if(Y < Ymin),
             Ymin = Y;
          end   
                
        end
    end
end
end
toc



    
    M(:,:,:,2) = newimage(:,:,:); %Image with +
    M(:,:,:,1) = newimage(:,:,:); %Unchanged image
    
 
    if(ran_once > 0),
        Xmid = ceil(((Xmax - Xmin)/2) + Xmin);
        Ymid = ceil(((Ymax - Ymin)/2) + Ymin);
        if ((Xmid == (vidHeight/2)) && (Ymid == (vidWidth/2))),
            %if in center, then go to where it was before
            Xmid = oldXmid;
            Ymid = oldYmid;
            
        else
            if (abs(Xmid+10) >= vidHeight),
                Xmid = (vidHeight - 10); 
            end
            if (abs(Ymid+10) >= vidWidth),
                Ymid = (vidWidth - 10); 
            end
            if (Ymid < 10),
                Ymid =10;
            end
            if (Xmid <10),
                Xmid = 10;
            end
        end
        
        M(Xmid,Ymid-9:Ymid+9,:,2)=0;
        M(Xmid-9:Xmid+9,Ymid,:,2)=0;
        M(Xmid,Ymid-9:Ymid+9,1,2)=255;
        M(Xmid-9:Xmid+9,Ymid,1,2)=255;
        %TODO - Box changes
        oldYmid = Ymid;
        oldXmid = Xmid;        
    end
    
    imagesc(M(:,:,:,2));
    pause(.05);
    ran_once = 1;
    Xmax = 0;
    YMax=0;
    Xmid = 0;
    Ymid = 0;
    Xmin = vidHeight;
    Ymin = vidWidth;
    
    
    %Uncomment below for movie tarcking
    %display('Ran');
    %percentdone = (i/nFrames)*100;
    %percentdone
%end

end

%BELOW USED FOR VIDEO ENCODING
writerObj = VideoWriter('output.avi', 'Motion JPEG AVI');
writerObj.FrameRate = vidFrameRate/2;
open(writerObj);
for k = startframe:totruns,
    k
    img = (M(:,:,:,k)); 
    writeVideo(writerObj, img);
end
close(writerObj);


