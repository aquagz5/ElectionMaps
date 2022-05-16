DATA Pres; 
	Infile "/home/u45007217/STS_2920/Project/presidential_general_election_2016_state.csv" dsd firstobs=2;
	Input delegates electoral_votes geo_name $:75. party $:25. is_winner $ name $:15. rank reporting state $:15. vote_pct votes;
	If MISSING(electoral_votes) THEN Delete;
Run;	

*Need to insert FIPS codes for each state into dataset
 We will match merge with dataset once cleaned up;
DATA FIPS;
INFILE DATALINES dsd; 
INPUT State $:15. FIPS; 
Datalines;
Alabama,01 
Alaska,02 
Arizona,04
Arkansas,05
California,06
Colorado,08
Connecticut,09
Delaware,10
Washington DC,11
Florida,12
Georgia,13
Hawaii,15
Idaho,16
Illinois,17
Indiana,18
Iowa,19
Kansas,20
Kentucky,21
Louisiana,22
Maine,23
Maryland,24
Massachusetts,25
Michigan,26
Minnesota,27
Mississippi,28 
Missouri,29
Montana,30 
Nebraska,31
Nevada,32 
New Hampshire,33
New Jersey,34
New Mexico,35
New York,36 
North Carolina,37
North Dakota,38
Ohio,39
Oklahoma,40
Oregon,41 
Pennsylvania,42
Rhode Island,44
South Carolina,45
South Dakota,46
Tennessee,47
Texas,48
Utah,49
Vermont,50
Virginia,51
Washington,53
West Virginia,54
Wisconsin,55
Wyoming,56
;
Run;

*Creating a dataset for map coordinates of US;
DATA mapUSA;
	SET MAPS.us;
	Where state ne 72; *do not want PR; 
Run;	

*Seperate the data from Trump votes of a state and Clinton votes for a state.
Only conserned with state and vote_pct, but we have to name vote_pct to 
trump_pct because we will evantually have clinton's vote_pct;

*Creating seperate DS with trump percentage;
Data Trump (Keep = state vote_pct Rename=(vote_pct=trump_pct)); 
	set Pres; 
	If name = "D. Trump" Then output;
Run;

*Creating seperate DS with Clinton percentage;
DATA Clinton (Keep= state vote_pct Rename= (vote_pct = clinton_pct)); 
	Set Pres; 
	If name = "H. Clinton" THEN OUTPUT; 
Run;	

*Sorting Data in order to match merge Clinton and Trump;
PROC SORT DATA = clinton;
	By state; 
Run;	

PROC SORT DATA = trump;
	By state; 
Run;	
	



*Combining Clinton and Trump
Obtaining Margins in terms of if Trump won or loss;
DATA State_Margins (Keep = state Margins);
	Merge Clinton Trump; 
	By state; 
	Margins = trump_pct - clinton_pct; 
	If state = "District of Col" Then State = "Washington DC";
	Label margins = "Winner";
Run;



*Combining FIPS data with margin of victory in order to correctly create map 
Creating map based of FIPS for each state;
PROC SORT DATA = fips;
	By state;
Run;

Proc Sort Data = state_margins;
	By state;
Run;	


DATA State_Margins (Rename = (FIPS = State) Drop = State);
	Merge state_margins FIPS;
	By state; 
Run;	

*Coppied code to get abbrevations of for state;
data maplabel;
   length function $ 8;
   retain flag 0 xsys ysys '2' hsys '3' when 'a' style "'Albany AMT'";
   set maps.uscenter(drop=long lat);

   where fipstate(state) ne 'PR'; 

   function='label'; text=fipstate(state); size=2.5; position='5';
  

   if ocean='Y' then               
      do;                          
         position='6'; output;    
         function='move';                                                      
         flag=1;
      end;                                            
   else if flag=1 then            
      do;                                                                   
         function='draw'; size=.5;
         flag=0;
      end;
   output;
run;





*Creating a PROC format to correspond the margin victory in terms
of Trump win or Clinton win (Remember- In terms of trump);
Proc format; 
value state_margins
0 - 100 = 'Trump'
-100 - 0 = 'Clinton'
;
Run;

*Create Map
Pattern blue comes first because it has lowest value;
pattern1 v=s c= blue;
pattern2 v=s c=red;
TITLE "2016 Electoral College";
proc gmap
map = mapUSA
data = state_margins;
id state;
choro margins /discrete coutline=black annotate=maplabel; 
format margins state_margins.; *Magic statements that corresponds pattern to who won; 
run;
quit;
	





	