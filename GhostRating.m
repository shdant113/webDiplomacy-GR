%Diplomacy ratings calculated using EIDRaS by Tony Nichols and George Heintzelman
%http://www.stabbeurfou.org/docs/articles/en/DP_S1998R_Diplomacys_New_Rating_System.html
%and
%http://uk.diplom.org/pouch//Email/Ratings/JDPR/describe.html
%Shitty code by Yonni

tic

clear all; close all;

% path  = 'C:\Users\Yonni Laptop\Google Drive\ghostRatingData.csv';
% M = importdata(path,','); %import csv


%First convert to csv because I don't know how to deal with 3 characters (i.e. ",") as the deliminator
M = importdata('ghostRatingData.csv',',');

x = find(cellfun('isempty', M.textdata(:,4)),1); %Beginning of player list

%variantID	gameID	userID	pot	gameOver	status	supplyCenterNo	potType	phaseMinutes	turn	processTime	pressType	IsBanned
results = M.textdata(2:x-1,:);
variantID = [cellfun(@str2num,results(1:end,1))];
gameID = [cellfun(@str2num,results(1:end,2))];
userID = [cellfun(@str2num,results(1:end,3))];
gameOver = cellstr(results(1:end,5));
status = cellstr(results(1:end,6));
supplyCentreNo = [cellfun(@str2num,results(1:end,7))];
potType = cellstr(results(1:end,8));
phaseMinutes = [cellfun(@str2num,results(1:end,9))];
pressType = cellstr(results(1:end,12));

numGames = max(gameID);

%id     username    IsBanned
playerInfo = M.textdata(x+1:end,1:3);
playerID = [cellfun(@str2num,playerInfo(1:end,1))];
username = cellstr(playerInfo(1:end,2));
isBanned = cellstr(playerInfo(1:end,3));
%playerRating = ones(length(playerID),1)*startRating;

disp(['Took ' num2str(toc/60) ' minutes to do that stupid loading thing'])

%%

%%% Enter Game Type for Data Anlysis %%% 
gameChoose = 99;     % (e.g. gameChoose = 1 for Classic)                 
pressChoose = 2;    % (e.g. pressChoose = 1 for Regular) 
potChoose = 1;      % (e.g. potChoose = 1 for WTA)
gameLength = 99;     % 1 for live, 2 for non-live
                    % Enter 99 for all
                
variantName(1) = {'Classic'};
variantName(2) = {'World_Diplomacy_IX'};
variantName(9) = {'The_Ancienct_Mediterranean'};
variantName(15) = {'France_vs_Austria'};
variantName(19) = {'Modern_Diplomacy_II'};
variantName(20) = {'Fall_of_the_American_Empire'};
variantName(23) = {'Germany_vs_Italy'};
variantName(57) = {'Known_World_901'};
variantName(99) = {'All'};

pressName(1) = {'Regular'};
pressName(2) = {'NoPress'};
pressName(3) = {'PublicPressOnly'};
pressName(4) = {'RuleBookPress'};
pressName(99)= {'All'};

potName(1) = {'Winner-takes-all'};
potName(2) = {'Points-per-supply-center'};
potName(3) = {'Sum-of-squares'};
potName(99) = {'All'};

minuteCutoff = 700; % Cutoff for phase length for non-live
gameLengthName(1) = {'Live'};
gameLengthName(2) = {'Non-live'};
gameLengthName(99) = {'All'};

startRating = 1000;
c = 0.002;

%%

%Add filter for banned players?

tic

playerRating = ones(length(playerID),1)*startRating;
Wins = zeros(length(playerID),1);
Draws = zeros(length(playerID),1);
Survives = zeros(length(playerID),1);
Defeats = zeros(length(playerID),1);
Resigns = zeros(length(playerID),1);
Games = zeros(length(playerID),1);
lastPlayed = zeros(length(playerID),1); %Add this

for n=1:numGames
    I=find(gameID==n);
    if ~isempty(I)
        if and(strcmp(potType(I(1),1),'Unranked')==0, ...
                and(or(potChoose==99,strcmp(potType(I(1),1),potName(potChoose))), ...
                and(or(gameChoose==99,variantID(I(1))==gameChoose), ...
                or(pressChoose==99,strcmp(pressType(I(1),1),pressName(pressChoose)))))) %getting weird, starting another IF
            if (and(gameLength==1,phaseMinutes(I(1))<minuteCutoff)||and(gameLength==2,phaseMinutes(I(1))>minuteCutoff))||gameLength==99
                
                playerIndex = arrayfun(@(x)find(playerID==x,1),userID(I)); %Index to call player info
                
                strength = exp(c*playerRating(playerIndex));
                X = length(I)*strength/sum(strength);
                S = zeros(length(I),1);
                
                winner  = find(strcmp(status(I), 'Won'));
                if ~isempty(winner)
                    S(winner)=1;
                    Wins(playerIndex(winner)) = Wins(playerIndex(winner)) + 1;
                end
                if isempty(winner)
                    draw = find(strcmp(status(I), 'Drawn'));
                    if strcomp(potType(I(1)),'Winner-takes-all')
                        S(draw) = 1/length(draw);
                    elseif strcomp(potType(I(1)),'Points-per-supply-center')
                        S(draw) = supplyCentreNo(I(draw));
                        
                    end
                    Draws(playerIndex(draw)) = Draws(playerIndex(draw)) + 1;
                end
                
                survive = find(strcmp(status(I), 'Survived'));
                Survives(playerIndex(survive)) = Survives(playerIndex(survive)) + 1;
                defeat = find(strcmp(status(I), 'Defeated'));
                Defeats(playerIndex(defeat)) = Defeats(playerIndex(defeat)) + 1;
                resign = find(strcmp(status(I), 'Resigned'));
                Resigns(playerIndex(resign)) = Resigns(playerIndex(resign)) + 1;
                Games = Wins+Draws+Survives+Defeats+Resigns;
                
                if strcmp(pressType(I(1)),pressName(1))||strcmp(pressType(I(1)),pressName(4)) %reggie or rulebook
                    P = 1;
                elseif strcmp(pressType(I(1)),pressName(2))%goonbat
                    P = 0.5;
                else
                    P = 0.8;
                end
                if phaseMinutes(I(1))<minuteCutoff
                    P = 0.3;
                end
                
                R = 2*sum(Games(playerIndex)>=7)/length(I); %fraction experienced opponents (>=7 games played)
                    %Edit by YF -> Changed from 1+sum to 2*sum to further discount provisional games
                A = 1; %variant adjustment. Do later.
                E = 1+40/(Games(playerIndex)+10);
                V = 7.5*A*P*R;
                              
                delta = V*E'.*(S*length(I)-X);
                playerRating(playerIndex) = playerRating(playerIndex) + delta;
                
                clear draw win defeat survive resign
            end
        end
    end
end

disp(['Game analysis lasted ' num2str(toc/60) ' minutes'])

%%
tic

playerInfo(:,4) = num2cell(playerRating);
playerInfo(:,5) = num2cell(Wins);
playerInfo(:,6) = num2cell(Draws);
playerInfo(:,7) = num2cell(Survives);
playerInfo(:,8) = num2cell(Defeats);
playerInfo(:,9) = num2cell(Resigns);
playerInfo(:,10) = num2cell(Games);

T = cell2table((playerInfo),'VariableNames',{'playerID','Username','isBanned','GhostRating','Wins','Draws','Survives','Defeats','Resigns','Games'});
writetable(T,['GR_Variant-' variantName{gameChoose} '_Press-' pressName{pressChoose} '_Pot-' potName{potChoose} '_Length-' gameLengthName{gameLength} '.dat'])

disp(['Saving data lasted ' num2str(toc/60) ' minutes'])