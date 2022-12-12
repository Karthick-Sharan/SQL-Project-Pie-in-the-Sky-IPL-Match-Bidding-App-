use ipl;
select * from ipl_user;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_player;
select * from ipl_team_players;
select * from ipl_tournament;
select * from ipl_match;	
select * from ipl_match_schedule;
select * from ipl_bidder_details;
select * from ipl_bidding_details;
select * from ipl_bidder_points;
select * from ipl_team_standings;


/*    Please build the needed tables from "IPL_PIESKY_Data MySQL Dump.sql" befor executing the below codes!!!      */


## 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select ibd.bidder_id, NO_OF_BIDS as Total_Bids, count(bid_status) as Bids_Won, (count(BID_STATUS)/NO_OF_BIDS)*100 as Win_Percentage
from ipl_bidding_details as ibd
join ipl_bidder_points as ibp
on ibd.bidder_id = ibp.bidder_id
where ibd.bid_status = 'won'
group by ibd.bidder_id, NO_OF_BIDS
order by win_percentage desc;




## 2.	Display the number of matches conducted at each stadium with stadium name, city from the database.

select std.STADIUM_ID, STADIUM_NAME, count(std.STADIUM_ID) as matches_conducted, CITY
from ipl_stadium as std
join ipl_match_schedule as ms
on std.STADIUM_ID = ms.STADIUM_ID
group by std.STADIUM_ID,STADIUM_NAME
order by matches_conducted desc;




## 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?

select STADIUM_ID,STADIUM_NAME,CITY,
(
(select count(*) from ipl_match im join ipl_match_schedule ims
on im.MATCH_ID = ims.MATCH_ID where ims.STADIUM_ID = std.STADIUM_ID and TOSS_WINNER=MATCH_WINNER) 
/ 
(select count(*) from ipl_match_schedule ims where ims.STADIUM_ID = std.STADIUM_ID) *100
) as 'Win Percentage when toss is won'
from ipl_stadium as std;

/*                without sub-query :               */

select s.stadium_id, stadium_name, city, sum(if(toss_winner=match_winner,1,0)) / sum(if(toss_winner=match_winner,1,1)) * 100 as P
from ipl_match_schedule ims
join ipl_match im
join ipl_stadium s
on ims.stadium_id = s.stadium_id
where ims.match_id = im.match_id
group by s.stadium_id order by s.stadium_id;




##  4.	Show the total bids along with bid team and team name.

select BID_TEAM, TEAM_NAME, count(BID_TEAM) as Total_bids
from ipl_bidding_details ibd
join ipl_team it
on ibd.BID_TEAM = it.TEAM_ID
group by BID_TEAM order by total_bids desc;




## 5.	Show the team id who won the match as per the win details.

select Match_id, (select team_name from ipl_team it  where if(im.match_winner = 1, it.team_id = im.team_id1, it.team_id = im.team_id2)) as 'Match Winner', 
  if(match_winner =1, team_id1, team_id2) as Winning_Team_ID,
  (select team_name from ipl_team it where if(im.match_winner = 2, it.team_id = im.team_id1, it.team_id = im.team_id2)) as 'Match against', win_details
from ipl_match im;

/*         without using sub-query :         */

select Match_id, team_name as Match_winner, team_id, win_details 
FROM ipl_team it
INNER JOIN ipl_match im
ON it.team_id = if(match_winner =1, team_id1, team_id2);



##   6.	Display total matches played, total matches won and total matches lost by team along with its team name.

select its.TEAM_ID, TEAM_NAME, sum(MATCHES_PLAYED)as 'Matches Played', sum(MATCHES_WON) as 'Matches Won', sum(MATCHES_LOST) as 'Matcehs Lost', sum(TOTAL_POINTS) as "Points"
from ipl_team_standings its
join ipl_team it
on its.team_id = it.team_id
group by its.team_id
order by Points desc;



##  7.	Display the bowlers for Mumbai Indians team.

select distinct ip.player_id, player_name, player_role, 'Mumbai Indians' as Team
from ipl_team_players itp
join ipl_player ip
on itp.player_id = ip.player_id
where team_id = 5 and player_role like '%bowler%';


##  8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounder in descending order.

select itp.team_id, team_name, player_role, count(ip.player_id) as 'No. of all-rounders'
from ipl_team_players itp
join ipl_player ip
on itp.player_id = ip.player_id
join ipl_team it
on itp.team_id = it.team_id
where player_role like '%all%'
group by itp.team_id, player_role
having count(ip.player_id) > 4
order by count(ip.player_id) desc; 

